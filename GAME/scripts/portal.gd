extends Area2D

@export var proxima_fase: PackedScene
var portal_ativo = false

@onready var audio_portal = $portal_audio

func _ready() -> void:
	visible = false
	monitoring = false

	if not body_entered.is_connected(entrar_no_portal):
		body_entered.connect(entrar_no_portal)

func _process(_delta: float) -> void:
	if portal_ativo:
		return

	var inimigos_vivos = get_tree().get_nodes_in_group("enemies")

	if inimigos_vivos.size() == 0:
		ativar_portal()

func ativar_portal() -> void:
	portal_ativo = true
	visible = true

	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_mask_value(3, true)

	monitoring = true
	print(">>> Todos os inimigos foram eliminados! O portal está aberto. <<<")

	# ✅ Loop configurado no Inspector do nó portal_audio
	audio_portal.play()

	await get_tree().process_frame
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			entrar_no_portal(body)

func entrar_no_portal(body: Node2D) -> void:
	print(">>> FÍSICA: Algo tocou no portal! Nome do nó: ", body.name)

	if body.is_in_group("player"):
		print(">>> GRUPO: Confirmado, é o jogador!")
		audio_portal.stop()

		if proxima_fase != null:
			print(">>> SUCESSO: Carregando a fase do Boss... <<<")
			get_tree().change_scene_to_packed(proxima_fase)
		else:
			print(">>> ERRO NO INSPETOR: Você esqueceu de arrastar a cena do Boss para este portal! <<<")
	else:
		print(">>> GRUPO REJEITADO: O nó '", body.name, "' não tem o grupo 'player'. <<<")
