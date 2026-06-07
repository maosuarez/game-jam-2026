extends Node2D

@onready var game_UI = $GameUI
@onready var glitch = $CanvasLayer/Glitch
@onready var entities = $Entities
@onready var pause_menu = $PauseMenu

var isPaused = false

func _ready():
	game_UI.visible = true
	AudioManager.bg_play_music(1.0)
	Global.level = self

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and !Global.player.isDead:
		if !isPaused:
			isPaused = true
			pause_menu.pause_game()
		else:
			isPaused = false
			pause_menu.resume_game()
