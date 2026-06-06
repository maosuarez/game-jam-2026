extends Area2D

@export var speed = 600.0
var direction = 1.0

func _ready():
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _physics_process(delta):
	position.x += speed * direction * delta

func _on_body_entered(body: Node2D):
	if body.is_in_group("enemies"):
		#print("Impact on ", body)
		body.glitch()
		queue_free()
