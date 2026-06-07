extends Node2D

@onready var game_UI = $GameUI
@onready var glitch = $CanvasLayer/Glitch

func _ready():
	game_UI.visible = true
	AudioManager.bg_play_music(1)

func _process(delta: float) -> void:
	pass
