extends CharacterBody2D

var health = 20
var speed = 50.0
var jump_force = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var distancia_ataque = 210.0
@export var distancia_acerto = 230.0

var tempo_pulando = 0.0
var intervalo_pulo = 3.0
var player = null
var is_dead = false
var is_hurt = false
var is_attacking = false
var pode_atacar = true

var laugh_timer = 0.0
var laugh_interval = 0.0
var hit_sound_index = 0

@onready var animated_sprite = $AnimatedSprite2D
@onready var audio_attack = $boss_attack
@onready var audio_death = $boss_death
@onready var audio_win = $boss_win
@onready var audio_laugh = $boss_laugh
@onready var hit_sounds = [
	$boss_hit1,
	$boss_hit2,
	$boss_hit3
]

func _ready():
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	_sortear_proximo_laugh()

func _sortear_proximo_laugh():
	laugh_interval = randf_range(6.0, 14.0)
	laugh_timer = 0.0

func _physics_process(delta):
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if is_hurt or is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	if player and not player.is_dead:
		var distance = global_position.distance_to(player.global_position)
		var direction = sign(player.global_position.x - global_position.x)

		if direction != 0:
			animated_sprite.flip_h = (direction < 0)

		if distance < distancia_ataque:
			if pode_atacar:
				velocity.x = 0
				atacar()
			else:
				velocity.x = 0
				if is_on_floor():
					animated_sprite.play("idle")
		else:
			# ✅ Laugh aleatório enquanto persegue
			laugh_timer += delta
			if laugh_timer >= laugh_interval and not audio_laugh.playing:
				audio_laugh.play()
				_sortear_proximo_laugh()

			velocity.x = direction * speed
			tempo_pulando += delta

			if is_on_floor() and tempo_pulando >= intervalo_pulo:
				velocity.y = jump_force
				tempo_pulando = 0.0

			if not is_on_floor():
				animated_sprite.play("jumping")
			else:
				animated_sprite.play("walking")
	else:
		# ✅ Player morreu — boss vence
		if not audio_win.playing and not is_dead:
			audio_win.play()
		velocity.x = 0
		if is_on_floor():
			animated_sprite.play("idle")

	move_and_slide()

func atacar():
	is_attacking = true
	pode_atacar = false
	animated_sprite.play("attacking")
	# ✅ Som de ataque
	audio_attack.play()

	await get_tree().create_timer(0.5).timeout

	if player and not player.is_dead and global_position.distance_to(player.global_position) < distancia_acerto:
		if player.has_method("take_damage"):
			var direcao_empurrao = 1.0 if player.global_position.x > global_position.x else -1.0
			player.take_damage(direcao_empurrao)

	await animated_sprite.animation_finished
	is_attacking = false

	await get_tree().create_timer(1.5).timeout
	pode_atacar = true

func take_damage():
	if is_dead or is_hurt:
		return
	health -= 1
	is_hurt = true

	# ✅ Som de hit alternado
	hit_sounds[hit_sound_index].play()
	hit_sound_index = (hit_sound_index + 1) % hit_sounds.size()

	animated_sprite.play("hit")

	if health <= 0:
		die()
	else:
		await animated_sprite.animation_finished
		is_hurt = false

func die():
	is_dead = true
	velocity.x = 0
	animated_sprite.play("death")
	# ✅ Som de morte
	audio_death.play()
	await animated_sprite.animation_finished
	await get_tree().create_timer(1.0).timeout
	queue_free()
