extends Node2D

@onready var tilemap: TileMapLayer = $Background
@onready var players = $Players
@onready var enemies = $Enemies
@onready var entities = $Entities
@onready var pause_menu = $PauseMenu

var active_player: CharacterBody2D
var isPaused = false

func _ready() -> void:
	active_player = players.active_player
	AudioManager.bg_play_music(3.0)
	Global.level = self

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if !isPaused:
			isPaused = true
			pause_menu.pause_game()
		else:
			isPaused = false
			pause_menu.resume_game()

func _physics_process(delta):
	_check_tile_mode()

func _check_tile_mode():
	var tile_pos = tilemap.local_to_map(tilemap.to_local(active_player.global_position))
	var tile_data = tilemap.get_cell_tile_data(tile_pos)
	
	if tile_data:
		var mode = tile_data.get_custom_data("game_mode")
		if mode == "topdown":
			GameMode.set_mode(GameMode.Mode.TOPDOWN)
		else:
			GameMode.set_mode(GameMode.Mode.METROIDVANIA)
		active_player = players.active_player
