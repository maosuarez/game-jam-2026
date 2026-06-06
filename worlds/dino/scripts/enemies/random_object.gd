extends RigidBody2D


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4

func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		var direction = sign(body.global_position.x - global_position.x)
		apply_impulse(Vector2(50.0 * direction, -400.0))
		await get_tree().create_timer(1.0).timeout
		queue_free()
