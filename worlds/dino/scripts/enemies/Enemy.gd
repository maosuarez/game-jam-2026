class_name Enemy
extends CharacterBody2D

@export var stats: DinoStats

@onready var ray_cast: RayCast2D = $RayCast
@onready var sprite: Sprite2D = $Sprite
@onready var glitch = $Glitch
@onready var hurtbox: HurtZone = $HurtZone
@onready var heal_scene = Ref.HealScene
@onready var rand_obj_scene = Ref.RandObjectScene

var hp: float
var base_damage: float
var recoil_stop: float = 800.0
var speed = 60.0
var acc = 100.0

var isDead = false
var canTurn = false

var direction = 1
var recoil_dir = 1
var recoil := Vector2.ZERO

func _ready() -> void:
	velocity.x = speed
	sprite.texture = load(stats.texturePath)
	hp = stats.hp
	base_damage = stats.base_damage
	recoil_stop = stats.recoil_stop
	speed = stats.speed
	acc = stats.acc
	hurtbox.damage = base_damage
	add_to_group("enemies")
	add_to_group("metroidvania")
	add_to_group("zombie") if stats.resource_name == "Zombie" else add_to_group("dino")
	sprite.material = sprite.material.duplicate()
	glitch.material = glitch.material.duplicate()
	await get_tree().create_timer(0.1).timeout
	canTurn = true

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if(recoil == Vector2.ZERO):
		sprite.material.set_shader_parameter("hit", false)
		velocity.x = move_toward(velocity.x, speed * direction, acc * delta)
	else:
		recoil = recoil.move_toward(Vector2.ZERO, recoil_stop * delta)
		velocity = recoil
		if(recoil_dir == self.direction):
			velocity.x += speed * direction
	
	if !isDead && canTurn && is_on_floor():
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
	else:
		hit_flash()

func hit_flash(times := 3):
	for i in times:
		sprite.material.set_shader_parameter("flash_amount", 1.0)
		await get_tree().create_timer(0.05).timeout
		sprite.material.set_shader_parameter("flash_amount", 0.0)
		await get_tree().create_timer(0.05).timeout

func kill():
	speed = 0.0
	recoil_stop /= 2.0
	isDead = true
	hurtbox.monitoring = false
	sprite.material.set_shader_parameter("isDead", true)
	var tween = create_tween()
	tween.tween_method(
		func(v): sprite.material.set_shader_parameter("flash_amount", v),
		0.0, 1.0, 0.5  # de 0 a 1 en 0.5 segundos
	)
	await tween.finished
	self.queue_free()

func change_direction(instant: bool = true):
	direction *= -1
	sprite.flip_h = (direction == stats.oriented)
	ray_cast.position.x *= -1
	ray_cast.target_position.x *= -1
	if(instant): velocity.x = speed * direction

func apply_recoil(direction: Vector2, force: float):
	if isDead:
		return
	recoil_dir = direction.x
	velocity.x = 0.0
	recoil = direction * force

func do_glitch():
	velocity = Vector2.ZERO
	isDead = true
	hurtbox.monitoring = false
	glitch.visible = true
	glitch.material.set_shader_parameter("glitch_intensity", 0.7)
	await get_tree().create_timer(randf_range(0.2, 0.5)).timeout
	
	var rand = randf()
	
	if rand < 0.5:
		var new_heal = heal_scene.instantiate()
		new_heal.global_position = global_position
		get_tree().current_scene.entities.add_child(new_heal)
	else:
		var new_obj = rand_obj_scene.instantiate()
		new_obj.global_position = global_position
		get_tree().current_scene.entities.add_child(new_obj)
	
	call_deferred("queue_free")
