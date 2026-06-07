extends CanvasLayer

@onready var general: VBoxContainer = $Control/Fondo/General

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func pause_game() -> void:
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(
		$Control/ColorRect,
		"color",
		Color8(0, 0, 0, 140), 0.1
	)
	visible = true
	general.visible = true
	set_bgMusic_db(-30.0)
	Engine.time_scale = 0.0

func resume_game() -> void:
	$Control/ColorRect.color = Color(0, 0, 0, 0)
	visible = false
	general.visible = false
	set_bgMusic_db(-15.0)
	Engine.time_scale = 1.0

func set_bgMusic_db(db: float) -> void:
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_ignore_time_scale(true)
	tween.tween_property(AudioManager.streamPlayers["BGMusic"], "volume_db", db, 0.3)
