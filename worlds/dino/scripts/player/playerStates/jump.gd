extends State

@export var jump_velocity: float = -500.0
@export var jump_cut_multiplier: float = 0.8

func enter():
	super()
	player.velocity.y = jump_velocity
	air_speed = abs(player.velocity.x)
	isRunning = false
	if Input.is_action_pressed("run"):
		isRunning = true

func physics_update(delta: float):
	if(player.isHurt):
		Transitioned.emit(self, "hit")
		return
	
	player.velocity.y += Global.gravity * delta
	
	if Input.is_action_just_released("jump") and player.velocity.y < 0.0:
		player.velocity.y *= jump_cut_multiplier
	
	var movement = handle_air_horizontal_movement(delta)
	
	player.velocity.x = move_toward(player.velocity.x, movement, stop_acc*delta)
	#player.move_and_slide()
	
	if player.velocity.y > 0:
		state_machine.states["fall"].isRunning = isRunning
		Transitioned.emit(self, "fall")
	
	if player.is_on_floor() && player.velocity.y > 0:
		isRunning = false
		if movement != 0:
			Transitioned.emit(self, "walk")
			return
		if player.velocity.x != 0:
			Transitioned.emit(self, "skid")
			return
		Transitioned.emit(self, "idle")
