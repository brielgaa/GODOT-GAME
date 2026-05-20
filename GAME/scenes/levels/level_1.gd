extends Node2D

@export var zombie_scene: PackedScene
var spawn_time = 5.0  # tempo em segundos entre spawns
var timer = 0.0

# Posições onde os zumbis vão aparecer
var spawn_points = [
	Vector2(1000, -200),
	Vector2(-500, -200),
	Vector2(1500, -200)
]

func _process(delta):
	timer += delta
	if timer >= spawn_time:
		timer = 0.0
		spawn_zombie()

func spawn_zombie():
	if zombie_scene == null:
		return
	var zombie = zombie_scene.instantiate()
	var spawn_pos = spawn_points[randi() % spawn_points.size()]
	zombie.global_position = spawn_pos
	add_child(zombie)
