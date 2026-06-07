extends CustomMenuButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	position = startpos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed():
	get_tree().change_scene_to_file("res://cutscenes/intro.tscn")
