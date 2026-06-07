extends Node2D

@onready var dino_player = $DinoPlayer
@onready var zombies_player = $ZombiesPlayer

var active_player: CharacterBody2D

func _ready():
	GameMode.mode_changed.connect(_on_mode_changed)
	active_player = $DinoPlayer

func _on_mode_changed(new_mode):
	print(new_mode)
	if new_mode == GameMode.Mode.TOPDOWN:
		_enter_topdown()
	else:
		_enter_metroidvania()
	Global.player = active_player

func _enter_topdown():
	zombies_player.global_position = dino_player.global_position
	zombies_player.visible = true
	dino_player.visible = false
	dino_player.process_mode = PROCESS_MODE_DISABLED
	zombies_player.process_mode = PROCESS_MODE_ALWAYS
	#zombies_player.camera.enabled = true
	#dino_player.camera.enabled = false
	active_player = zombies_player

func _enter_metroidvania():
	dino_player.global_position = zombies_player.global_position
	dino_player.visible = true
	zombies_player.visible = false
	zombies_player.process_mode = PROCESS_MODE_DISABLED
	dino_player.process_mode = PROCESS_MODE_ALWAYS
	#dino_player.camera.enabled = true
	#zombies_player.camera.enabled = false
	active_player = dino_player
