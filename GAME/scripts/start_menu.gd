extends Control

const GAME_SCENE = "res://scenes/levels/level_1.tscn"

@onready var btn_sound = $btn_sound
@onready var music = $music_startgame

func _ready():
	get_tree().paused = false
	music.play()

func _on_start_button_pressed():
	btn_sound.play()
	await btn_sound.finished
	get_tree().change_scene_to_file(GAME_SCENE)
