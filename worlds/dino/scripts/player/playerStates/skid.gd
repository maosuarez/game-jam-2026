extends State

func enter() -> void:
	print("Skid")

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
	player.velocity.x = move_toward(player.velocity.x, 0, stop_acc*delta)
	#player.move_and_slide()
	if player.velocity.x == 0:
		Transitioned.emit(self, "idle")
	if !player.is_on_floor():
		Transitioned.emit(self, "fall")
