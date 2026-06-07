extends Node2D

@export var tilemap: TileMapLayer

const m_zombie_scene = preload("res://worlds/dino/scenes/zombie.tscn")
const td_green_dino_scene = preload("res://worlds/zombie/scenes/green_dino.tscn")
const td_zombie_scene = preload("res://worlds/zombie/scenes/zombie_basic.tscn")
const m_green_dino_scene = preload("res://worlds/dino/scenes/green_dino.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	for enemy in get_children():
		_check_tile_mode(enemy)

func _check_tile_mode(enemy: CharacterBody2D):
	var tile_pos = tilemap.local_to_map(tilemap.to_local(enemy.global_position))
	var tile_data = tilemap.get_cell_tile_data(tile_pos)
	
	if tile_data:
		var mode = tile_data.get_custom_data("game_mode")
		if mode == "topdown" && enemy.is_in_group("metroidvania"):
			var topdown_enemy = td_green_dino_scene.instantiate() if enemy.is_in_group("dino") else td_zombie_scene.instantiate()
			topdown_enemy.global_position = enemy.global_position
			Global.level.enemies.add_child(topdown_enemy)
			enemy.call_deferred("queue_free")
		elif mode == "metroidvania" && enemy.is_in_group("topdown"):
			var metroidvania_enemy = m_zombie_scene.instantiate() if enemy.is_in_group("zombie") else m_green_dino_scene.instantiate()
			metroidvania_enemy.global_position = enemy.global_position
			Global.level.enemies.add_child(metroidvania_enemy)
			enemy.call_deferred("queue_free")
