extends Enemy

@onready var floor_detect = $FloorDetect

var target: Node2D = null

func _physics_process(delta):
	if target:
		if sign(target.global_position.x - global_position.x) != direction:
			change_direction(false)
	
	if(recoil == Vector2.ZERO):
		sprite.material.set_shader_parameter("hit", false)
		velocity.x = move_toward(velocity.x, speed * direction, acc * delta)
	else:
		recoil = recoil.move_toward(Vector2.ZERO, recoil_stop * delta)
		velocity = recoil
		if(recoil_dir == self.direction):
			velocity.x += speed * direction
	
	if !isDead && canTurn && is_on_floor():
		if (is_on_wall()  && !target):
			change_direction()
		if(!ray_cast.is_colliding() && (!target && floor_detect.is_colliding())):
			change_direction()
			target = null;
	
	if !is_on_floor():
		velocity.y += Global.gravity * delta
	move_and_slide()

func _on_detection_range_body_entered(body: Node2D):
	if body.is_in_group("player"):
		target = body

func _on_detection_range_body_exited(body: Node2D):
	if body.is_in_group("player"):
		target = null
