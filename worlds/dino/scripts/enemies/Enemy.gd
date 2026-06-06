class_name Enemy
extends CharacterBody2D

@onready var ray_cast: RayCast2D = $RayCast
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: HurtZone = $HurtZone

@export var hp: float
@export var base_damage: float
@export var recoil_stop: float = 800.0
@export var speed = 60.0
@export var acc = 100.0

var isDead = false

var direction = 1
var recoil_dir = 1
var recoil := Vector2.ZERO

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if(recoil == Vector2.ZERO):
		velocity.x = move_toward(velocity.x, speed * direction, acc * delta)
	else:
		recoil = recoil.move_toward(Vector2.ZERO, recoil_stop * delta)
		velocity = recoil
		if(recoil_dir == self.direction):
			velocity.x += speed * direction
	
	if !isDead:
		if is_on_wall() || !ray_cast.is_colliding():
			change_direction()
	
	if !is_on_floor():
		velocity.y += Global.gravity * delta
	move_and_slide()

func hurt(damage: float):
	hp -= damage
	print("HP: ", hp, " ", self)
	if(hp <= 0.0):
		kill()

func kill():
	speed = 0.0
	recoil_stop /= 2.0
	isDead = true
	hurtbox.monitoring = false
	await get_tree().create_timer(0.5).timeout
	self.queue_free()

func change_direction():
	direction *= -1
	animated_sprite.flip_h = (direction == -1)
	ray_cast.position.x *= -1
	ray_cast.target_position.x *= -1
	velocity.x = speed * direction

func apply_recoil(direction: Vector2, force: float):
	recoil_dir = direction.x
	velocity.x = 0.0
	recoil = direction * force
