class_name PlayerState
extends Node

signal Transitioned

var player: Player
@onready var state_machine: Node = self.get_parent()

const run_speed: float = 150
const walk_speed: float = 100
const stop_acc: float = 900
const start_acc: float = 1500
const run_acc: float = 1500

var air_speed
var isRunning: bool = false

func enter():
	#print(self.name)
	if(player.animation_component && !player.isAttacking && !Global.player.isDead):
		player.animation_component.animation_player.play(self.name)

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	pass

func handle_horizontal_movement(delta: float):
	var movement = 0
	if !Global.player.isDead:
		if Input.is_action_pressed("run"):
			movement = Input.get_axis('move_left', 'move_right') * move_toward(abs(player.velocity.x), run_speed, run_acc*delta)
		else:
			movement = Input.get_axis('move_left', 'move_right') * move_toward(abs(player.velocity.x), walk_speed, start_acc*delta)
		
		if movement != 0:
			player.velocity.x = movement
		
		if(Global.player.isHurt): movement = 0
	return movement

func handle_air_horizontal_movement(delta: float):
	var movement = 0
	if !Global.player.isDead:
		air_speed = move_toward(air_speed, walk_speed, stop_acc*delta)
		if Input.is_action_just_released("run"):
			isRunning = false
		if isRunning:
			air_speed = run_speed
		
		movement = Input.get_axis('move_left', 'move_right') * air_speed
	
	return movement
