extends Node2D


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.collision_layer = 0
		var tween = create_tween()
		tween.tween_method(
			func(v): Global.level.glitch.material.set_shader_parameter("glitch_intensity", v),
			0.0, 0.5, 3.0
		)
		await tween.finished
		get_tree().change_scene_to_file("res://worlds/zombie/scenes/zombie_world.tscn")
