extends CustomMenuButton

func _ready() -> void:
	super()

func _on_pressed() -> void:
	Global.level.isPaused = false
	Global.level.pause_menu.resume_game()
