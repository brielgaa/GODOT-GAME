extends Area2D

var direction = Vector2.RIGHT
var speed = 400.0

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	animated_sprite.play("book")
	animated_sprite.flip_h = direction == Vector2.LEFT

func _physics_process(delta):
	animated_sprite.flip_h = direction == Vector2.LEFT
	position += direction * speed * delta
	if position.x > 2000 or position.x < -2000:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemies") or body.is_in_group("boss"):
		body.take_damage()
		queue_free()
	elif not body.is_in_group("player"):
		queue_free()
