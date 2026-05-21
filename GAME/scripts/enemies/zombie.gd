extends CharacterBody2D

var health = 3
var speed = 60.0
var is_dead = false
var is_hurt = false
var is_attacking = false
var can_attack = true

# A distância máxima que o zumbi consegue "enxergar" o jogador
var aggro_distance = 300.0 

var player = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	# 1. A GRAVIDADE SEMPRE ACONTECE
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. SE ESTIVER INCAPACITADO
	if is_dead or is_hurt or is_attacking:
		velocity.x = 0 
		move_and_slide() 
		return

	# 3. LÓGICA DE VISÃO E PERSEGUIÇÃO
	if player and not player.is_dead:
		var distance = global_position.distance_to(player.global_position)
		
		if distance < 80:
			# Está perto o suficiente: PARA e ATACA
			velocity.x = 0
			if not is_attacking and can_attack:
				attack()
		elif distance <= aggro_distance:
			# O jogador entrou no raio de visão (menor que 300): PERSEGUE
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * speed
			
			if direction.x != 0:
				animated_sprite.flip_h = direction.x > 0
			
			if animated_sprite.animation != "walking":
				animated_sprite.play("walking")
		else:
			# O jogador está vivo, mas longe demais: FICA PARADO
			velocity.x = 0
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
	else:
		# Se o jogador não existir, fica parado
		velocity.x = 0
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

	# 4. APLICA O MOVIMENTO
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
	
	await get_tree().create_timer(1.5).timeout
	queue_free()
