extends Control

# Altere para o caminho exato da sua cena de jogo
const GAME_SCENE = "res://scenes/levels/level_1.tscn"

func _ready():
	# Garante que o jogo processe normalmente
	get_tree().paused = false

func _on_start_button_pressed():
	# Muda para a cena do level principal
	var error = get_tree().change_scene_to_file(GAME_SCENE)
	
	if error != OK:
		print("Erro ao carregar a cena. Verifique o caminho em GAME_SCENE.")
