extends State

var was_on_floor = false

func enter() -> void:
	super()
	player.velocity.y = 0.0

func update(delta: float):
	if(player.isHurt):
		Transitioned.emit(self, "hit")
		return
	
	if Input.is_action_just_pressed('jump') and (player.is_on_floor() or !player.coyote_time.is_stopped()):
		Transitioned.emit(self, "jump")
		return
	if Input.is_action_pressed('run'):
		Transitioned.emit(self, "run")
		return

func physics_update(delta: float):
	super(delta)
	var movement = handle_horizontal_movement(delta)
	
	#player.move_and_slide()
	if was_on_floor and !player.is_on_floor():
		player.coyote_time.start();
		was_on_floor = false
	
	if !player.is_on_floor() and player.coyote_time.is_stopped():
		Transitioned.emit(self, "fall")
		return
	
	if movement == 0 and player.velocity.x != 0:
		Transitioned.emit(self, "skid")
		return
	if movement == 0:
		Transitioned.emit(self, "idle")
		return
	
	if player.is_on_floor():
		was_on_floor = true
