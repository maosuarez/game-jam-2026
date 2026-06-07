extends Node2D


func _ready() -> void:
	$CanvasLayer/VideoStreamPlayer.play()

func _process(delta: float) -> void:
	pass


func _on_video_stream_player_finished() -> void:
	var tween = create_tween()
	tween.tween_method(
		func(v): $CanvasLayer/ColorRect.color.a = v,
		0.0, 1.0, 0.5
	)
	await tween.finished
	get_tree().change_scene_to_file("res://worlds/dino/scenes/dino_world.tscn")
