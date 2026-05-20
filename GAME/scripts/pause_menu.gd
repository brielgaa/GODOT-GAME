extends Control

func _ready():
	# Garante que o menu comece invisível quando a fase carregar
	hide()

func _input(event):
	# "ui_cancel" é a tecla ESC nativa da Godot
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	var novo_estado = !get_tree().paused
	get_tree().paused = novo_estado
	visible = novo_estado
	
	# Puxa o foco para o teclado/WASD funcionar no menu de pausa
	if novo_estado:
		$CenterContainer/VBoxContainer/ResumeButton.grab_focus()

func _on_resume_button_pressed():
	toggle_pause()

func _on_quit_button_pressed():
	# Despausa a engine antes de sair para evitar travamentos no menu principal
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")
