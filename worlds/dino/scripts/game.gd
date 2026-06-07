extends Node2D

@onready var game_UI = $GameUI
@onready var health_bar = $GameUI/Control/MarginContainer/ProgressBar
@onready var glitch = $CanvasLayer/Glitch

func _ready():
	health_bar.max_value = Global.player.max_hp
	game_UI.visible = true

func _process(delta: float) -> void:
	health_bar.value = Global.player.hp
