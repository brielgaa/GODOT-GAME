extends CharacterBody2D

var hud = null
@onready var animated_sprite = $AnimatedSprite2D

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

@export var projectile_scene: PackedScene

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _safe_update_hearts(value: int):
	# Se ainda não sabe quem é o hud, procura-o pelo grupo
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

	print(get_parent())
	print(hud)
	animated_sprite.flip_h = false
	add_to_group("player")

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

	# --- LÓGICA DE ESCADA VS GRAVIDADE ---
	if esta_na_escada:
		# 1. Desliga a gravidade e permite subir/descer com W e S (ou setas)
		var direcao_vertical = Input.get_axis("ui_up", "ui_down")
		velocity.y = direcao_vertical * SPEED
		jump_count = 0 # Renova o pulo para poderes saltar da escada
	else:
		# 2. Comportamento normal com gravidade quando não está na escada
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			jump_count = 0

	# --- PULO NORMAL ---
	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jumps:
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	# --- ANDAR PARA OS LADOS ---
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		if not is_attacking:
			animated_sprite.flip_h = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("attack") and not attack_cooldown:
		attack()

	if Input.is_action_just_pressed("shoot") and not attack_cooldown:
		shoot()

	move_and_slide()
	update_animation()

func update_animation():
	if is_hurt or is_attacking:
		return

	# --- 1. LÓGICA DA ESCADA ---
	if esta_na_escada:
		if animated_sprite.animation != "climbing":
			animated_sprite.play("climbing") # Mude o nome aqui se necessário
			
		# Se não estiver se movendo nem para cima/baixo nem pros lados, congela o frame
		if velocity.y == 0 and velocity.x == 0:
			animated_sprite.pause()
		else:
			animated_sprite.play() # Volta a tocar se estiver se movendo
		
		return # Para a função aqui para não rodar as animações de chão

	# --- 2. RETORNO AO CHÃO (Despausar) ---
	# Garante que a animação despause caso ele tenha pulado/saído da escada parado
	if not animated_sprite.is_playing():
		animated_sprite.play()

	# --- 3. ANIMAÇÕES NORMAIS ---
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
	# Corrige animação invertida
	animated_sprite.flip_h = not current_flip
	animated_sprite.play("attacking")

	# --- LÓGICA DE DANO (O PULO DO GATO) ---
	# Pega todos os inimigos da fase
	var todos_inimigos = get_tree().get_nodes_in_group("enemies")
	
	for inimigo in todos_inimigos:
		# Se o inimigo estiver a menos de 90 pixels de distância (seu alcance)
		if global_position.distance_to(inimigo.global_position) < 200:
			if inimigo.has_method("take_damage"):
				inimigo.take_damage()
	# ----------------------------------------

	await get_tree().create_timer(0.5).timeout

	# Volta direção original
	animated_sprite.flip_h = current_flip

	is_attacking = false
	attack_cooldown = false

func shoot():

	# Impede spam
	if attack_cooldown:
		return

	# Sem munição
	if ammo <= 0:
		return

	# Sem cena do projétil
	if projectile_scene == null:
		return

	attack_cooldown = true
	is_attacking = true

	var current_flip = animated_sprite.flip_h

	animated_sprite.play("throwing")
	animated_sprite.flip_h = current_flip

	await get_tree().create_timer(0.4).timeout

	var projectile = projectile_scene.instantiate()

	get_parent().add_child(projectile)

	projectile.global_position = global_position + Vector2(
		50 if current_flip else -50,
		-50
	)

	projectile.direction = Vector2.RIGHT if current_flip else Vector2.LEFT

	# ↓↓↓ DIMINUI UMA VEZ SÓ ↓↓↓
	ammo -= 1

	_safe_update_ammo(ammo, max_ammo)

	animated_sprite.flip_h = current_flip

	is_attacking = false

	await get_tree().create_timer(0.3).timeout

	attack_cooldown = false

# Chamado por itens de vida no chão
func collect_health() -> bool:
	# 1. Se a vida já estiver cheia, recusa o coração imediatamente
	if health >= max_health:
		return false
		
	# 2. Se precisa de cura, adiciona 1 e atualiza o HUD
	health += 1
	_safe_update_hearts(health)
	
	# 3. Manda o "Sinal Verde" para o coração se apagar do mapa!
	return true

# Chamado por itens de munição no chão
func collect_ammo(amount: int):
	ammo = min(ammo + amount, max_ammo)
	_safe_update_ammo(ammo, max_ammo)

func take_damage(knockback_dir: float = 0.0):
	if is_hurt or is_dead or is_invincible:
		return

	health -= 1
	_safe_update_hearts(health)

	# Knockback — knockback_dir deve ser -1.0 ou 1.0 vindo do inimigo
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
	await get_tree().create_timer(1.5).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")
