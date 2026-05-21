extends Area2D

var direction = Vector2.LEFT
var speed = 300.0

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	animated_sprite.play("flying")
	animated_sprite.flip_h = direction == Vector2.RIGHT
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	animated_sprite.flip_h = direction == Vector2.RIGHT
	position += direction * speed * delta
	if position.x > 3000 or position.x < -3000:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage()
		queue_free()
	elif not body.is_in_group("enemies"):
		queue_free()
