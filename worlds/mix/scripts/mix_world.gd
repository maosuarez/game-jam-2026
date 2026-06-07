extends Node2D

@onready var tilemap: TileMapLayer = $Background
@onready var players = $Players
var active_player: CharacterBody2D

func _ready() -> void:
	active_player = players.active_player
	AudioManager.bg_play_music(3)

func _process(delta: float) -> void:
	pass

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
