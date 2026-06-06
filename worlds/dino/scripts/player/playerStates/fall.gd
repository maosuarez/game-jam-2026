extends State

func enter():
	super()
	air_speed = abs(player.velocity.x)
	if state_machine.current_state.name != "jump" && Input.is_action_pressed("run"):
		isRunning = true

func physics_update(delta: float):
	super(delta)
	if(player.isHurt):
		Transitioned.emit(self, "hit")
		return
	
	player.velocity.y += Global.gravity * delta
	
	var movement = handle_air_horizontal_movement(delta)
	
	player.velocity.x = move_toward(player.velocity.x, movement, stop_acc*delta)
	#player.move_and_slide()
	
	if Input.is_action_just_pressed("jump") && player.jump_buffer.is_stopped():
		player.jump_buffer.start()
		#print("Jump Buffer Started")
	
	if player.is_on_floor():
		isRunning = false
		if !player.jump_buffer.is_stopped():
			player.jump_buffer.stop()
			Transitioned.emit(self, "jump")
			return
		if movement != 0 && Input.is_action_pressed("run"):
			Transitioned.emit(self, "run")
			return
		if movement != 0:
			Transitioned.emit(self, "walk")
			return
		if player.velocity.x != 0:
			Transitioned.emit(self, "skid")
			return
		Transitioned.emit(self, "idle")
		return
