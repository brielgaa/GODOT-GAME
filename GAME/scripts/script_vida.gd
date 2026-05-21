extends Area2D

func _ready() -> void:
	# Forçamos o motor gráfico a ligar o sinal via código.
	# Isso ignora qualquer erro que possa estar a acontecer na aba de Sinais do editor!
	if not body_entered.is_connected(coletar_vida):
		body_entered.connect(coletar_vida)

func coletar_vida(body: Node2D) -> void:
	print("TESTE DE COLISÃO: Um nó chamado '", body.name, "' tocou na vida!")
	
	# Usando "player" com letra MINÚSCULA para bater exatamente com o seu script
	if body.is_in_group("player"):
		if body.has_method("collect_health"):
			body.collect_health()
			queue_free()
