extends CharacterBody2D

var health = 3
var speed = 60.0
var is_dead = false
var is_hurt = false
var is_attacking = false
var can_attack = true
var aggro_distance = 300.0
var player = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var walk_sound_timer = 0.0
var walk_sound_interval = 0.4
var walk_sound_index = 0
var hit_sound_index = 0
var groan_timer = 0.0
var groan_interval = 0.0 # vai ser sorteado

@onready var animated_sprite = $AnimatedSprite2D
@onready var audio_death = $zombie_dying
@onready var audio_groan = $zombie_groaning
@onready var step_sounds = [
	$zombie_step1,
	$zombie_step2,
	$zombie_step3,
	$zombie_step4,
	$zombie_step5
]
@onready var hit_sounds = [
	$zombie_hit1,
	$zombie_hit2,
	$zombie_hit3
]

func _ready():
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	_sortear_proximo_gemido()

func _sortear_proximo_gemido():
	# Sorteia um intervalo entre 5 e 12 segundos
	groan_interval = randf_range(5.0, 12.0)
	groan_timer = 0.0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_dead or is_hurt or is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	if player and not player.is_dead:
		var distance = global_position.distance_to(player.global_position)

		if distance < 80:
			velocity.x = 0
			walk_sound_timer = 0.0
			if not is_attacking and can_attack:
				attack()
		elif distance <= aggro_distance:
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * speed
			if direction.x != 0:
				animated_sprite.flip_h = direction.x > 0
			if animated_sprite.animation != "walking":
				animated_sprite.play("walking")

			# ✅ Passos em sequência
			walk_sound_timer += delta
			if walk_sound_timer >= walk_sound_interval:
				walk_sound_timer = 0.0
				step_sounds[walk_sound_index].play()
				walk_sound_index = (walk_sound_index + 1) % step_sounds.size()

			# ✅ Gemido aleatório enquanto anda
			groan_timer += delta
			if groan_timer >= groan_interval:
				if not audio_groan.playing:
					audio_groan.play()
				_sortear_proximo_gemido()
		else:
			velocity.x = 0
			walk_sound_timer = 0.0
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
	else:
		velocity.x = 0
		walk_sound_timer = 0.0
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

	move_and_slide()

func attack():
	is_attacking = true
	can_attack = false
	animated_sprite.play("attacking")

	await get_tree().create_timer(0.6).timeout

	if player and not player.is_dead and global_position.distance_to(player.global_position) < 80:
		if player.has_method("take_damage"):
			var direcao_empurrao = 1.0 if player.global_position.x > global_position.x else -1.0
			player.take_damage(direcao_empurrao)

	is_attacking = false
	await get_tree().create_timer(1.5).timeout
	can_attack = true

func take_damage():
	if is_hurt or is_dead:
		return
	health -= 1
	if health <= 0:
		die()
		return

	is_hurt = true
	hit_sounds[hit_sound_index].play()
	hit_sound_index = (hit_sound_index + 1) % hit_sounds.size()

	var current_flip = animated_sprite.flip_h
	animated_sprite.play("hit")
	animated_sprite.flip_h = current_flip

	await get_tree().create_timer(0.4).timeout
	animated_sprite.flip_h = current_flip
	is_hurt = false

func die():
	is_dead = true
	velocity.x = 0
	var current_flip = animated_sprite.flip_h
	animated_sprite.play("die")
	animated_sprite.flip_h = current_flip
	audio_death.play()

	await get_tree().create_timer(1.5).timeout
	queue_free()
