extends State

var was_on_floor = false

func update(delta: float):
	if(player.isHurt):
		Transitioned.emit(self, "hit")
		return
	
	if Input.is_action_just_pressed('jump') and (player.is_on_floor() or !player.coyote_time.is_stopped()):
		Transitioned.emit(self, "jump")
		return
	if Input.is_action_just_released('run'):
		Transitioned.emit(self, "walk")
		return

func physics_update(delta: float):
	var movement = handle_horizontal_movement(delta)
	
	if movement != 0:
		player.velocity.x = movement
	#player.move_and_slide()
	if was_on_floor and !player.is_on_floor():
		player.coyote_time.start();
		was_on_floor = false
	
	if movement == 0:
		Transitioned.emit(self, "skid")
		return
	
	if !player.is_on_floor() and player.coyote_time.is_stopped():
		Transitioned.emit(self, "fall")
	
	if player.is_on_floor():
		was_on_floor = true
