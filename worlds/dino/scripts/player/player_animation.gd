extends Node2D

@export var player: Player
@onready var sprite = $PlayerSprite
@onready var animation_player = $PlayerSprite/PlayerAnimationPlayer
var movement = 1

func _ready():
	pass

func _process(delta: float):
	pass

func _physics_process(delta: float):
	movement = Input.get_axis("move_left", "move_right")
	
	if(Global.player.isDead): movement = 0
	if movement < 0:
		player.attackbox.position.x = -37
		sprite.flip_h = true
	elif movement > 0:
		player.attackbox.position.x = 0
		sprite.flip_h = false
