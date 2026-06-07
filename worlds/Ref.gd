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

##Projectile Textures
var Bala = "res://worlds/zombie/assets/sprites/player/Bala.png"
var Cuchillo = "res://worlds/zombie/assets/sprites/items/Kunai.png"

##Background Music
var BG_Music = {
	1.0: "res://worlds/dino/assets/Nivel-Dinosaurio.mp3",
	2.0: "res://worlds/zombie/Nivel-Zombies.mp3",
	2.1: "res://worlds/zombie/Nivel-Zombies-Boss.mp3",
	3.0: "res://worlds/mix/Nivel-Final.mp3"
}


var Heart = "res://worlds/zombie/assets/sprites/player/CorazonVida.png"
var EmptyHeart = "res://worlds/zombie/assets/sprites/player/CorazonVacio.png"
