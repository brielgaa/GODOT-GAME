extends Area2D

func _ready() -> void:
	if body_entered.is_connected(coletar_vida):
		body_entered.disconnect(coletar_vida)
	body_entered.connect(coletar_vida)

func coletar_vida(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("collect_health"):
			# Pergunta ao jogador: "Posso curar-te?"
			var curou_com_sucesso = body.collect_health()
			
			# Se o jogador respondeu "true", o coração apaga-se. 
			# Se respondeu "false", o coração fica lá no chão à espera!
			if curou_com_sucesso == true:
				print("Vida recuperada! Deletando coração...")
				queue_free()
