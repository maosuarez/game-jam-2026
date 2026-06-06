extends Area2D

func _on_body_entered(body: Node2D) -> void:
	#print(body)
	if(body.is_in_group("player") || body.is_in_group("enemies")):
		body.kill()
	else:
		body.queue_free()
