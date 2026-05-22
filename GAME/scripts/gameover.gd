extends Control

func _on_tryagain_pressed() -> void:

	print(">>> O BOTÃO FOI CLICADO! <<<")
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
	
func _on_exit_pressed() -> void:
	# Fecha o jogo e volta para o Windows
	get_tree().quit()
