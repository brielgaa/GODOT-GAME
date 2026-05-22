extends Area2D

func esta_na_escada(body: Node2D) -> void:
	if body.name == "Player":
		body.esta_na_escada = true

func saiu_da_escada(body: Node2D) -> void:
	if body.name == "Player":
		body.esta_na_escada = false
