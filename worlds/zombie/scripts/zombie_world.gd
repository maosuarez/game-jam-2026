extends Node2D

@onready var wave_manager: Node = $WaveManager
@onready var hud: CanvasLayer = $HUD
@onready var glitch_trigger: Area2D = $GlitchTrigger
@onready var player: CharacterBody2D = $Player
@onready var glitch = $CanvasLayer/Glitch
@onready var boss_alert = $BossAlert
@onready var pause_menu = $PauseMenu

var isPaused = false

func _ready() -> void:
	wave_manager.all_completed.connect(_on_all_completed)
	glitch_trigger.level_completed.connect(_on_level_completed)
	hud.setup(player, wave_manager)
	player.took_damage.connect(wave_manager.deduct_score)
	player.died.connect(_on_player_died)
	Global.player = player
	Global.level = self
	glitch.material.set_shader_parameter("glitch_intensity", 0.0)
	AudioManager.streamPlayers["BGMusic"].stop()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and !Global.player.isDead:
		if !isPaused:
			isPaused = true
			pause_menu.pause_game()
		else:
			isPaused = false
			pause_menu.resume_game()

func _on_all_completed() -> void:
	hud.layer = 1
	glitch_trigger.activate()

func _on_level_completed() -> void:
	modulate = Color.WHITE

func _on_player_died() -> void:
	wave_manager.stop()
	#get_tree().create_timer(3.0).timeout.connect(get_tree().reload_current_scene)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()
