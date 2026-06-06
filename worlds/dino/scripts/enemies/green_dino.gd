extends Enemy

@export var speed = 60.0

var direction = 1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: HurtZone = $HurtZone
@onready var hitbox: Area2D = $HitBox

func _ready() -> void:
	super()
	hurtbox.damage = base_damage
	hitbox.add_to_group("enemies")

func _process(delta: float) -> void:
	if !ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if !ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	position.x += direction * speed * delta

func _physics_process(delta: float) -> void:
	pass
