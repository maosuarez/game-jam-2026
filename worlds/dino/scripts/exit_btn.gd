extends CustomMenuButton

func _on_pressed() -> void:
	super()
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://menu/hub.tscn")
