extends Control

@onready var btn_sound = $btn_sound

func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	var novo_estado = !get_tree().paused
	get_tree().paused = novo_estado
	visible = novo_estado
	if novo_estado:
		$CenterContainer/VBoxContainer/ResumeButton.grab_focus()

func _on_resume_button_pressed():
	btn_sound.play()
	await btn_sound.finished
	toggle_pause()

func _on_quit_button_pressed():
	btn_sound.play()
	await btn_sound.finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")
