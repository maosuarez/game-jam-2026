extends CanvasLayer

@onready var hp_container: HBoxContainer = $Control/MarginContainer/HPContainer
var max_hp: int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_hp = Global.player.max_hp
	Global.player.connect("hp_changed", _on_hp_changed)
	_refresh_hearts(max_hp)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_hp_changed(new_hp: int) -> void:
	_refresh_hearts(new_hp)

func _refresh_hearts(current_hp: int) -> void:
	if hp_container == null:
		return
	for child in hp_container.get_children():
		child.queue_free()
	for i in range(max_hp):
		var heart = ColorRect.new()
		heart.custom_minimum_size = Vector2(20, 20)
		heart.color = Color(0.8, 0.1, 0.1) if i < current_hp else Color(0.3, 0.3, 0.3)
		hp_container.add_child(heart)
