extends Control

@onready var btn_sound = $btn_sound

func _on_tryagain_pressed() -> void:
	btn_sound.play()
	await btn_sound.finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_exit_pressed() -> void:
	btn_sound.play()
	await btn_sound.finished
	get_tree().quit()
