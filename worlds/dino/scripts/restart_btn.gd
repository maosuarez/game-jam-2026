extends CustomMenuButton

func _on_pressed():
	Global.level.pause_menu.resume_game()
	self.get_tree().reload_current_scene()
