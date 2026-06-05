class_name Player
extends CharacterBody2D

@onready var coyote_time: Timer = $PlayerMovement/CoyoteTime
@onready var jump_buffer: Timer = $PlayerMovement/JumpBuffer
@onready var movement_component = $PlayerMovement
@onready var animation_component = $PlayerAnimation

#var attacking: bool = false

func _ready():
	Global.player = self

func _process(delta: float):
	movement_component._process(delta)
	animation_component._process(delta)

func _physics_process(delta: float):
	move_and_slide()
	movement_component._physics_process(delta)
