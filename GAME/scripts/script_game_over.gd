extends Node2D

func continuar_jogo() -> void:
	ScriptGlobal.inicializar()
	get_tree().change_scene_to_file("res://cena_fase.tscn")
	
func ir_para_inicio() -> void:
	ScriptGlobal.inicializar()
	get_tree().change_scene_to_file("res://cena_inicio.tscn")
