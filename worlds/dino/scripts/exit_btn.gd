extends CustomMenuButton

func _on_pressed() -> void:
	super()
	get_tree().quit()
