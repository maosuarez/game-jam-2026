extends Node2D

@export var radius: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ShootPoint.position = Vector2(radius, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
