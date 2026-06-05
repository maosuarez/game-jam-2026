extends Node2D

@export var player: Player
@onready var sprite = $PlayerSprite
@onready var animation_tree = $PlayerSprite/PlayerAnimationTree
var movement = 1
var aux = 0

func _ready():
	animation_tree.active = false
	sprite.texture = (Ref.PlayerSheet)
	aux = 0
	animation_tree.active = true

func _process(delta: float):
	pass

func _physics_process(delta: float):
	movement = Input.get_axis("move_left", "move_right")
	if movement < 0:
		sprite.flip_h = true
	elif movement > 0:
		sprite.flip_h = false
