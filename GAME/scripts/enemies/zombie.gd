extends CharacterBody2D

var health = 3
var speed = 60.0
var is_dead = false
var is_hurt = false
var is_attacking = false
var can_attack = true

var player = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	print("Player encontrado: ", player)

func _physics_process(delta):
	# 1. A GRAVIDADE SEMPRE ACONTECE (mesmo atacando/morto, para não flutuar)
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. SE ESTIVER INCAPACITADO (Morto, apanhando ou batendo)
	if is_dead or is_hurt or is_attacking:
		velocity.x = 0 # Zera a velocidade para ele não deslizar no chão
		move_and_slide() # Aplica a física e para o script aqui
		return

	# 3. LÓGICA DE PERSEGUIÇÃO AUTÔNOMA
	if player and not player.is_dead:
		var distance = global_position.distance_to(player.global_position)
		
		if distance < 80:
			# Está perto o suficiente: PARA e ATACA
			velocity.x = 0
			if not is_attacking and can_attack:
				attack()
		else:
			# Está mais longe que 40: PERSEGUE
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * speed
			
			if direction.x != 0:
				animated_sprite.flip_h = direction.x > 0
			
			if animated_sprite.animation != "walking":
				animated_sprite.play("walking")
	else:
		# Se o jogador não existir na tela, fica parado
		velocity.x = 0
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

	# 4. APLICA O MOVIMENTO
	move_and_slide()

func attack():
	is_attacking = true
	can_attack = false # Trava novos ataques
	animated_sprite.play("attacking")
	
	# Tempo exato da animação do soco
	await get_tree().create_timer(0.6).timeout
	
	# Checa o acerto
	if player and not player.is_dead and global_position.distance_to(player.global_position) < 80: # <-- Reduza de 110 para uns 55
		
		if player.has_method("take_damage"):
			var direcao_empurrao = 1.0 if player.global_position.x > global_position.x else -1.0
			player.take_damage(direcao_empurrao)
			
	is_attacking = false # O zumbi volta a poder andar e ficar em Idle
	
	# --- O DELAY ---
	# O zumbi espera 1.5 segundos (ou o tempo que quiser) antes de dar o próximo soco
	await get_tree().create_timer(1.5).timeout
	can_attack = true # Libera o próximo soco

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
