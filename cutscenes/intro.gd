extends Node2D


func _ready() -> void:
	$CanvasLayer/VideoStreamPlayer.play()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		_on_video_stream_player_finished()


func _on_video_stream_player_finished() -> void:
	var tween = create_tween()
	tween.tween_method(
		func(v): $CanvasLayer/ColorRect.color.a = v,
		0.0, 1.0, 0.5
	)
	var tween2 = create_tween()
	tween2.tween_method(
		func(v): $CanvasLayer/VideoStreamPlayer.volume_db = v,
		1.0, -40.0, 0.5
	)
	await tween.finished
	get_tree().change_scene_to_file("res://menu/hub.tscn")
