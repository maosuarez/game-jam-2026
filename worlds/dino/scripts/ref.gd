extends Node

##Animation Sheets
var PlayerSheets = {
	"normal": load("res://worlds/dino/assets/entities/player/player_sheet.png"),
	"dino": load("res://worlds/dino/assets/entities/player/player_sheet_dino.png")
}

##Spawnable scenes
var GlitchRayScene: PackedScene = load("res://worlds/dino/scenes/glitch_ray.tscn")
var HealScene: PackedScene = load("res://worlds/dino/scenes/heal.tscn")
var RandObjectScene: PackedScene = load("res://worlds/dino/scenes/random_object.tscn")
