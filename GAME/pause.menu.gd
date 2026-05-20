extends CanvasLayer

# A cena deve ter process_mode = Always para funcionar com pausa

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_resume_pressed():
	get_tree().paused = false
	hide()

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
