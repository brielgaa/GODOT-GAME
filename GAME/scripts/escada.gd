extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func esta_na_escada(body: Node2D) -> void:
	if (body.name=="Player"):
		body.esta_na_escada = true

func saiu_da_escada(body: Node2D) -> void:
	if (body.name=="Player"):
		body.esta_na_escada = false
		
		
		
		
