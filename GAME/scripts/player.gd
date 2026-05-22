extends CharacterBody2D

var hud = null
@onready var animated_sprite = $AnimatedSprite2D
@onready var ladder_sounds = [
	$Ladder_hit1,
	$Ladder_hit2,
	$Ladder_hit3,
	$Ladder_hit4,
	$Ladder_hit5
]
@onready var step_sounds = [
	$pl_step1,
	$pl_step2,
	$pl_step3,
	$pl_step4,
	$pl_step5,
	$pl_step6,
	$pl_step7,
	$pl_step8
]
@onready var audio_attack = $pl_attack
@onready var audio_throwing = $pl_throwing
@onready var audio_pain = $pl_pain
@onready var audio_death = $pl_death
@onready var jump_sounds = [
	$pl_jump1,
	$pl_jump2
]

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const KNOCKBACK_FORCE = Vector2(300, -150)
const INVINCIBILITY_TIME = 1.5
const BLINK_INTERVAL = 0.1

var max_health = 3
var health = 3
var max_ammo = 10
var ammo = 10

var is_dead = false
var is_hurt = false
var is_attacking = false
var attack_cooldown = false
var is_invincible = false

var jump_count = 0
var max_jumps = 2
var esta_na_escada = false

var ladder_sound_index = 0
var ladder_sound_timer = 0.0
var ladder_sound_interval = 0.3

var step_sound_index = 0
var step_sound_timer = 0.0
var step_sound_interval = 0.35

@export var projectile_scene: PackedScene

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _safe_update_hearts(value: int):
	if not hud:
		hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_hearts(value)

func _safe_update_ammo(current: int, maximum: int):
	if not hud:
		hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_ammo(current, maximum)

func _ready():
	animated_sprite.flip_h = false
	add_to_group("player")
	for s in step_sounds:
		s.volume_db = -20.0

func _physics_process(delta):
	if is_dead:
		if not is_on_floor() and not esta_na_escada:
			velocity.y += gravity * delta
		velocity.x = 0
		move_and_slide()
		return

	if Input.is_action_just_pressed("pause"):
		var pause_menu = get_node_or_null("/root/Game/PauseMenu")
		if pause_menu:
			get_tree().paused = true
			pause_menu.show()
		return

	if esta_na_escada:
		var direcao_vertical = Input.get_axis("ui_up", "ui_down")
		velocity.y = direcao_vertical * SPEED
		jump_count = 0

		if direcao_vertical != 0:
			ladder_sound_timer += delta
			if ladder_sound_timer >= ladder_sound_interval:
				ladder_sound_timer = 0.0
				ladder_sounds[ladder_sound_index].play()
				ladder_sound_index = (ladder_sound_index + 1) % ladder_sounds.size()
		else:
			ladder_sound_timer = ladder_sound_interval
	else:
		if not is_on_floor():
			velocity.y += gravity * delta
			step_sound_timer = 0.0
		else:
			jump_count = 0

	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jumps:
		velocity.y = JUMP_VELOCITY
		# ✅ Toca pl_jump1 no primeiro pulo e pl_jump2 no segundo
		jump_sounds[jump_count].play()
		jump_count += 1

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		if not is_attacking:
			animated_sprite.flip_h = direction > 0
		if is_on_floor() and not esta_na_escada:
			step_sound_timer += delta
			if step_sound_timer >= step_sound_interval:
				step_sound_timer = 0.0
				step_sounds[step_sound_index].play()
				step_sound_index = (step_sound_index + 1) % step_sounds.size()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		step_sound_timer = 0.0

	if Input.is_action_just_pressed("attack") and not attack_cooldown:
		attack()

	if Input.is_action_just_pressed("shoot") and not attack_cooldown:
		shoot()

	move_and_slide()
	update_animation()

func update_animation():
	if is_hurt or is_attacking:
		return

	if esta_na_escada:
		if animated_sprite.animation != "climbing":
			animated_sprite.play("climbing")
		if velocity.y == 0 and velocity.x == 0:
			animated_sprite.pause()
		else:
			animated_sprite.play()
		return

	if not animated_sprite.is_playing():
		animated_sprite.play()

	if not is_on_floor():
		if animated_sprite.animation != "jumping":
			animated_sprite.play("jumping")
	elif velocity.x != 0:
		if animated_sprite.animation != "walking":
			animated_sprite.play("walking")
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

func attack():
	if attack_cooldown:
		return

	is_attacking = true
	attack_cooldown = true

	var current_flip = animated_sprite.flip_h
	animated_sprite.flip_h = not current_flip
	animated_sprite.play("attacking")
	audio_attack.play()

	var todos_inimigos = get_tree().get_nodes_in_group("enemies")
	for inimigo in todos_inimigos:
		if global_position.distance_to(inimigo.global_position) < 240:
			if inimigo.has_method("take_damage"):
				inimigo.take_damage()

	await get_tree().create_timer(0.5).timeout
	animated_sprite.flip_h = current_flip
	is_attacking = false
	attack_cooldown = false

func shoot():
	if attack_cooldown:
		return
	if ammo <= 0:
		return
	if projectile_scene == null:
		return

	attack_cooldown = true
	is_attacking = true

	var current_flip = animated_sprite.flip_h
	animated_sprite.play("throwing")
	animated_sprite.flip_h = current_flip
	audio_throwing.play()

	await get_tree().create_timer(0.4).timeout

	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position + Vector2(
		50 if current_flip else -50,
		-50
	)
	projectile.direction = Vector2.RIGHT if current_flip else Vector2.LEFT

	ammo -= 1
	_safe_update_ammo(ammo, max_ammo)
	animated_sprite.flip_h = current_flip
	is_attacking = false

	await get_tree().create_timer(0.3).timeout
	attack_cooldown = false

func collect_health() -> bool:
	if health >= max_health:
		return false
	health += 1
	_safe_update_hearts(health)
	return true

func collect_ammo(amount: int):
	ammo = min(ammo + amount, max_ammo)
	_safe_update_ammo(ammo, max_ammo)

func take_damage(knockback_dir: float = 0.0):
	if is_hurt or is_dead or is_invincible:
		return

	health -= 1
	_safe_update_hearts(health)

	if knockback_dir != 0.0:
		velocity = Vector2(KNOCKBACK_FORCE.x * knockback_dir, KNOCKBACK_FORCE.y)

	if health <= 0:
		die()
		return

	is_hurt = true
	is_invincible = true

	var current_flip = animated_sprite.flip_h
	animated_sprite.play("hit")
	animated_sprite.flip_h = current_flip
	audio_pain.play()

	_start_blink()

	await get_tree().create_timer(0.5).timeout
	animated_sprite.flip_h = current_flip
	is_hurt = false

	await get_tree().create_timer(INVINCIBILITY_TIME - 0.5).timeout
	is_invincible = false
	animated_sprite.modulate.a = 1.0

func _start_blink():
	var total = 0.0
	while total < INVINCIBILITY_TIME and not is_dead:
		animated_sprite.modulate.a = 0.2
		await get_tree().create_timer(BLINK_INTERVAL).timeout
		animated_sprite.modulate.a = 1.0
		await get_tree().create_timer(BLINK_INTERVAL).timeout
		total += BLINK_INTERVAL * 2

func die():
	is_dead = true
	var current_flip = animated_sprite.flip_h
	animated_sprite.play("death")
	animated_sprite.flip_h = current_flip
	audio_death.play()  # ✅
	await get_tree().create_timer(3).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/gameover.tscn")
