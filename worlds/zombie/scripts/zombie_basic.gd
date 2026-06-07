extends "res://worlds/zombie/scripts/base_zombie.gd"

func _ai_process(_delta: float) -> void:
	var to_player := player.global_position - global_position
	var dist := to_player.length()
	var dir := to_player / dist if dist > 0.0 else Vector2.ZERO

	var move_dir := (dir + _get_separation() * 0.4).normalized()
	velocity = move_dir * speed
	anim_tree.set("parameters/blend_position", dir)
	move_and_slide()

	if sprite:
		sprite.flip_h = move_dir.x < 0
