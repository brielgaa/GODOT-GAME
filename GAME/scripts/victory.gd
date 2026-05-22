extends Control

func _on_tryagain_pressed() -> void:
	# Garante que o jogo não está pausado
	get_tree().paused = false
	
	# Volta para a fase inicial para jogar tudo de novo!
	# IMPORTANTE: Confirme se este é o caminho exato da sua fase 1
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_exit_pressed() -> void:
	# Fecha o jogo e volta para a área de trabalho
	get_tree().quit()
