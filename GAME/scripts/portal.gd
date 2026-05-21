extends Area2D

# Cria o espaço no Inspetor para arrastar o arquivo da fase do Boss
@export var proxima_fase: PackedScene

var portal_ativo = false

func _ready() -> void:
	# O portal começa invisível e com a física totalmente desligada
	visible = false
	monitoring = false
	
	# Garante a conexão segura do sinal de colisão
	if not body_entered.is_connected(entrar_no_portal):
		body_entered.connect(entrar_no_portal)

func _process(_delta: float) -> void:
	# Se o portal já apareceu, não precisamos continuar contando
	if portal_ativo:
		return
		
	# Pega todos os nós que pertencem ao grupo "enemies" atualmente na fase
	var inimigos_vivos = get_tree().get_nodes_in_group("enemies")
	
	# Se a lista estiver vazia (tamanho 0), ativa o portal!
	if inimigos_vivos.size() == 0:
		ativar_portal()

func ativar_portal() -> void:
	portal_ativo = true
	visible = true      
	
	# Força o portal a sintonizar as camadas 1, 2 e 3 (onde o seu player deve estar)
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_mask_value(3, true)
	
	monitoring = true   
	print(">>> Todos os inimigos foram eliminados! O portal está aberto. <<<")
	
	# Truque anti-fantasma: 
	# Espera o motor gráfico atualizar a física por um frame e vê se alguém JÁ ESTÁ lá dentro
	await get_tree().process_frame
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			entrar_no_portal(body)

func entrar_no_portal(body: Node2D) -> void:
	# 1. Teste básico: O portal deteta qualquer toque?
	print(">>> FÍSICA: Algo tocou no portal! Nome do nó: ", body.name)
	
	if body.is_in_group("player"):
		print(">>> GRUPO: Confirmado, é o jogador!")
		
		if proxima_fase != null:
			print(">>> SUCESSO: Carregando a fase do Boss... <<<")
			get_tree().change_scene_to_packed(proxima_fase)
		else:
			print(">>> ERRO NO INSPETOR: Você esqueceu de arrastar a cena do Boss para este portal! <<<")
	else:
		print(">>> GRUPO REJEITADO: O nó '", body.name, "' não tem o grupo 'player'. <<<")
