extends "res://worlds/zombie/scripts/base_enemy.gd"

signal died(zombie)

const POWERUP_SCENE = preload("res://worlds/zombie/scenes/powerup.tscn")

@export var drop_chance: float = 0.10

func _on_death() -> void:
	died.emit(self)
	if randf() < drop_chance:
		_drop_powerup()
	queue_free()

func _drop_powerup() -> void:
	var powerup := POWERUP_SCENE.instantiate()
	powerup.global_position = global_position
	get_tree().current_scene.add_child(powerup)
