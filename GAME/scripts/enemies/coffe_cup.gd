extends CharacterBody2D

var health = 2
var is_dead = false
var is_hurt = false
var is_attacking = false
var can_attack = true
var player = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const JUMP_VELOCITY = -400.0
var jump_timer = 0.0
var jump_interval = 2.0
var attack_range = 400.0

@export var projectile_scene: PackedScene
@onready var animated_sprite = $AnimatedSprite2D
@onready var audio_death = $coffecup_broken
@onready var audio_throw = $coffecup_throw

func _ready():
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	jump_timer += delta
	if jump_timer >= jump_interval and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_timer = 0.0

	if is_dead or is_hurt or is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	if player and not player.is_dead:
		animated_sprite.flip_h = player.global_position.x < global_position.x
		var distance = global_position.distance_to(player.global_position)
		if distance < attack_range and can_attack:
			can_attack = false
			is_attacking = true
			attack()

	velocity.x = 0
	if not is_attacking and animated_sprite.animation != "idle":
		animated_sprite.play("idle")
	move_and_slide()

func attack():
	animated_sprite.play("attack")
	await get_tree().create_timer(0.5).timeout
	if projectile_scene and player and not player.is_dead:
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position
		projectile.direction = (player.global_position - global_position).normalized()
		# ✅ Toca som de arremesso
		audio_throw.play()
	is_attacking = false
	await get_tree().create_timer(2.0).timeout
	can_attack = true

func take_damage():
	if is_hurt or is_dead:
		return
	health -= 1
	if health <= 0:
		die()
		return
	is_hurt = true
	animated_sprite.play("idle")
	await get_tree().create_timer(0.4).timeout
	is_hurt = false

func die():
	is_dead = true
	velocity.x = 0
	animated_sprite.play("death")
	audio_death.play()
	await get_tree().create_timer(1.5).timeout
	queue_free()
