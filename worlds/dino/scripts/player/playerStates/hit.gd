extends PlayerState

@export var kbx_speed = 100.0
@export var kby_speed = -200.0

func enter():
	super()
	player.velocity.x = kbx_speed * player.kb_dir
	player.velocity.y = kby_speed
	player.kb_timer.start()

func physics_update(delta: float):
	player.recoil = Vector2.ZERO
	player.velocity.y += Global.gravity * delta

func _on_kb_timer_timeout() -> void:
	if !player.is_on_floor():
		state_machine.states["fall"].isRunning = isRunning
		Transitioned.emit(self, "fall")
	else:
		isRunning = false
		Transitioned.emit(self, "skid")

func exit():
	player.velocity.x = move_toward(player.velocity.x, 0.0, 50.0)
	player.isHurt = false
