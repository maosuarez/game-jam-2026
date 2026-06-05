extends State

func enter():
	super()
	print("Idle")
	player.velocity.y = 0.0
	player.velocity.x = 0.0

func update(delta: float):
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		Transitioned.emit(self, "jump")
		return
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		if Input.is_action_pressed("run"):
			Transitioned.emit(self, "run")
		else:
			Transitioned.emit(self, "walk")

func physics_update(delta: float):
	if !player.is_on_floor():
		Transitioned.emit(self, "fall")
