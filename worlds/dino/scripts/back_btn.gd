extends CustomMenuButton

signal GoToGeneral

func _on_pressed():
	emit_signal("GoToGeneral")
