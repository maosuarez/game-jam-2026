extends CharacterBody2D

signal died
signal hp_changed(new_hp)
signal took_damage(amount)

const PROJECTILE_SCENE = preload("res://worlds/zombie/scenes/projectile.tscn")

@export var speed: float = 200.0
@export var max_hp: int = 5
@export var shoot_cooldown: float = 0.3
@export var damage: int = 1

var hp: int
var shoot_timer: float = 0.0
var double_shot: bool = false
var damage_boost: bool = false
var speed_boost: bool = false
var _boost_timers: Dictionary = {}

@onready var shoot_point: Marker2D = $ShootPoint
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $HitBox

func _ready() -> void:
	hp = max_hp
	hp_changed.emit(hp)
	add_to_group("player")

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_shoot(delta)
	_update_boost_timers(delta)

func _handle_movement(_delta: float) -> void:
	var direction := Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	direction = direction.normalized()
	var current_speed = speed * (1.5 if speed_boost else 1.0)
	velocity = direction * current_speed
	move_and_slide()

	if direction != Vector2.ZERO:
		sprite.flip_h = direction.x < 0
		sprite.play("walk")
	else:
		sprite.play("idle")

func _handle_shoot(delta: float) -> void:
	shoot_timer -= delta
	if Input.is_action_pressed("shoot") and shoot_timer <= 0.0:
		shoot_timer = shoot_cooldown
		_fire_projectile()

func _fire_projectile() -> void:
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - shoot_point.global_position).normalized()
	_spawn_projectile(dir)
	if double_shot:
		var perp = Vector2(-dir.y, dir.x) * 12.0
		_spawn_projectile(dir, perp)
		_spawn_projectile(dir, -perp)

func _spawn_projectile(dir: Vector2, offset: Vector2 = Vector2.ZERO) -> void:
	var proj = PROJECTILE_SCENE.instantiate()
	proj.global_position = shoot_point.global_position + offset
	proj.direction = dir
	proj.damage = damage * (2 if damage_boost else 1)
	get_tree().current_scene.add_child(proj)

func take_damage(amount: int) -> void:
	hp -= amount
	hp = max(hp, 0)
	hp_changed.emit(hp)
	took_damage.emit(amount)
	if hp <= 0:
		died.emit()
		queue_free()

func heal(amount: int) -> void:
	hp = min(hp + amount, max_hp)
	hp_changed.emit(hp)

func apply_powerup(type: String) -> void:
	match type:
		"heal":
			heal(2)
		"speed":
			speed_boost = true
			_boost_timers["speed"] = 8.0
		"double_shot":
			double_shot = true
			_boost_timers["double_shot"] = 8.0
		"damage_boost":
			damage_boost = true
			_boost_timers["damage_boost"] = 8.0

func _update_boost_timers(delta: float) -> void:
	var keys = _boost_timers.keys()
	for key in keys:
		_boost_timers[key] -= delta
		if _boost_timers[key] <= 0.0:
			_boost_timers.erase(key)
			match key:
				"speed":
					speed_boost = false
				"double_shot":
					double_shot = false
				"damage_boost":
					damage_boost = false
