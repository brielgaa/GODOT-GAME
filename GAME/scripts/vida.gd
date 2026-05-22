extends Area2D

@onready var heart_sound = $heart_sound

func _ready() -> void:
	if body_entered.is_connected(coletar_vida):
		body_entered.disconnect(coletar_vida)
	body_entered.connect(coletar_vida)

func coletar_vida(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("collect_health"):
			var curou_com_sucesso = body.collect_health()
			if curou_com_sucesso == true:
				print("Vida recuperada! Deletando coração...")
				heart_sound.play()
				await heart_sound.finished
				queue_free()
