extends Node2D

@onready var wave_manager: Node = $WaveManager
@onready var hud: CanvasLayer = $HUD
@onready var glitch_trigger: Area2D = $GlitchTrigger
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	wave_manager.all_completed.connect(_on_all_completed)
	glitch_trigger.level_completed.connect(_on_level_completed)
	hud.setup(player, wave_manager)
	player.took_damage.connect(wave_manager.deduct_score)
	player.died.connect(_on_player_died)

func _on_all_completed() -> void:
	glitch_trigger.activate()

func _on_level_completed() -> void:
	modulate = Color.WHITE
	get_tree().change_scene_to_file("res://hub/hub.tscn")

func _on_player_died() -> void:
	wave_manager.stop()
	get_tree().create_timer(3.0).timeout.connect(get_tree().reload_current_scene)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()
