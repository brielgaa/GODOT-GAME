extends CanvasLayer

@onready var ammo_label = $AmmoLabel
@onready var hearts = [
	$Heart1,
	$Heart2,
	$Heart3
]

var heart_full_texture: Texture2D = preload("res://assets/sprites/ui/heart.png")
var heart_empty_texture: Texture2D = preload("res://assets/sprites/ui/empty_heart.png")

func _ready():
	add_to_group("hud")
	update_hearts(3)
	update_ammo(10, 10)

func update_hearts(current: int):
	for i in range(hearts.size()):
		if i < current:
			hearts[i].texture = heart_full_texture
		else:
			hearts[i].texture = heart_empty_texture

func update_ammo(current: int, maximum: int):
	ammo_label.text = "Livros: %d/%d" % [current, maximum]
