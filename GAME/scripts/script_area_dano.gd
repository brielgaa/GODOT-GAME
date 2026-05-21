extends Area2D

@export var valor_dano = 1

func causar_dano(body: Node2D) -> void:
	if (body.name=="Personagem"):
		body.colidindo_com_inimigo = true
		body.valor_dano = valor_dano
		body.sofrer_dano()

func finalizar_colisao(body: Node2D) -> void:
	if (body.name=="Personagem"):
		body.colidindo_com_inimigo = false
