extends Area2D

signal level_completed

var _active: bool = false
var _tween: Tween = null

func _ready() -> void:
	monitoring = false
	monitorable = false

func activate() -> void:
	if _active:
		return
	_active = true
	monitoring = true
	set_deferred("monitorable", true)
	_start_glitch_effect()
	await get_tree().create_timer(2.0).timeout
	level_completed.emit()

func _start_glitch_effect() -> void:
	# Oscillate modulate to create glitch visual on the parent scene
	var scene_root = get_tree().current_scene
	if scene_root == null:
		return
	_tween = create_tween()
	_tween.set_loops()
	_tween.tween_property(scene_root, "modulate", Color(1.2, 0.8, 1.2), 0.1)
	_tween.tween_property(scene_root, "modulate", Color(0.8, 1.2, 0.8), 0.1)
	_tween.tween_property(scene_root, "modulate", Color(1.1, 1.1, 0.7), 0.08)
	_tween.tween_property(scene_root, "modulate", Color.WHITE, 0.12)
