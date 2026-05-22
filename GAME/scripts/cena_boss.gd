extends Node2D

@onready var music = $music_bossphase

func _ready():
	music.play()
