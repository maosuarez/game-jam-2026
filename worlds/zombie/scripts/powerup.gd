extends Area2D

enum PowerUpType { HEAL, SPEED, DOUBLE_SHOT, DAMAGE_BOOST }

@export var type: PowerUpType = PowerUpType.HEAL

var _type_names: Array = ["heal", "speed", "double_shot", "damage_boost"]

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Randomly assign type if not set by spawner
	type = randi() % 4 as PowerUpType
	_update_sprite()
	body_entered.connect(_on_body_entered)

func _update_sprite() -> void:
	if sprite == null:
		return
	# Tint the sprite based on type for visual distinction
	match type:
		PowerUpType.HEAL:
			sprite.modulate = Color(1, 0.3, 0.3)
		PowerUpType.SPEED:
			sprite.modulate = Color(0.3, 1, 0.3)
		PowerUpType.DOUBLE_SHOT:
			sprite.modulate = Color(0.3, 0.3, 1)
		PowerUpType.DAMAGE_BOOST:
			sprite.modulate = Color(1, 0.8, 0.2)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("apply_powerup"):
		body.apply_powerup(_type_names[type])
		queue_free()
