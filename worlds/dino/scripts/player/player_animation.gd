extends Node2D

@export var player: Player
@onready var sprite = $PlayerSprite
@onready var animation_player = $PlayerSprite/PlayerAnimationPlayer
var movement = 1

func _ready():
	sprite.material = sprite.material.duplicate()

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

func hit_flash(times := 3):
	for i in times:
		sprite.material.set_shader_parameter("flash_amount", 1.0)
		await get_tree().create_timer(0.05).timeout
		sprite.material.set_shader_parameter("flash_amount", 0.0)
		await get_tree().create_timer(0.05).timeout
