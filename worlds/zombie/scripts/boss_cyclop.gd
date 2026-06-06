extends CharacterBody2D

signal phase_changed(phase)
signal hit_player(damage)
signal defeated

const PROJECTILE_SCENE = preload("res://worlds/zombie/scenes/projectile.tscn")
const ZOMBIE_BASIC_SCENE = preload("res://worlds/zombie/scenes/zombie_basic.tscn")

@export var speed_phase1: float = 50.0
@export var speed_phase2: float = 90.0
@export var hp: int = 40
@export var damage: int = 3
@export var xp_value: int = 200

var max_hp: int = 40
var phase: int = 1
var player: CharacterBody2D = null
var _shoot_timer: float = 0.0
var _summon_timer: float = 0.0
var _hit_cooldown: float = 0.0
var _current_speed: float = 50.0
var _flash_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	max_hp = hp
	_current_speed = speed_phase1
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	_hit_cooldown -= delta
	_update_flash(delta)

	if player == null:
		player = _find_player()
	if player == null:
		return

	_check_phase_transition()
	_handle_movement(delta)
	_handle_shooting(delta)

	if phase == 2:
		_handle_summon(delta)

func _check_phase_transition() -> void:
	if phase == 1 and hp <= max_hp / 2:
		phase = 2
		_current_speed = speed_phase2
		phase_changed.emit(phase)
		if sprite:
			sprite.modulate = Color(1.8, 0.3, 0.3)

func _handle_movement(_delta: float) -> void:
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * _current_speed
	move_and_slide()

	if sprite:
		sprite.flip_h = dir.x < 0

	if global_position.distance_to(player.global_position) < 56.0 and _hit_cooldown <= 0.0:
		_hit_cooldown = 1.5
		hit_player.emit(damage)
		if player.has_method("take_damage"):
			player.take_damage(damage)

func _handle_shooting(delta: float) -> void:
	var interval = 1.2 if phase == 2 else 2.5
	_shoot_timer -= delta
	if _shoot_timer <= 0.0:
		_shoot_timer = interval
		_fire_at_player()

func _fire_at_player() -> void:
	if player == null:
		return
	var count = 3 if phase == 2 else 1
	var spread = TAU / 16.0
	for i in range(count):
		var angle_offset = (i - (count - 1) / 2.0) * spread
		var base_dir = (player.global_position - global_position).normalized()
		var dir = base_dir.rotated(angle_offset)
		var proj = PROJECTILE_SCENE.instantiate()
		proj.global_position = global_position
		proj.direction = dir
		proj.damage = 2
		proj.speed = 280.0
		proj.set_meta("enemy_projectile", true)
		get_tree().current_scene.add_child(proj)

func _handle_summon(delta: float) -> void:
	_summon_timer -= delta
	if _summon_timer <= 0.0:
		_summon_timer = 5.0
		for i in range(3):
			var zombie = ZOMBIE_BASIC_SCENE.instantiate()
			var angle = (TAU / 3.0) * i
			zombie.global_position = global_position + Vector2(cos(angle), sin(angle)) * 90.0
			get_tree().current_scene.add_child(zombie)

func _update_flash(delta: float) -> void:
	_flash_timer -= delta
	if _flash_timer <= 0.0 and sprite:
		if phase == 2:
			sprite.modulate = Color(1.8, 0.3, 0.3)
		else:
			sprite.modulate = Color.WHITE

func _find_player() -> CharacterBody2D:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null

func take_damage(amount: int) -> void:
	hp -= amount
	_flash_timer = 0.12
	if sprite:
		sprite.modulate = Color(3.0, 0.1, 0.1)
	if hp <= 0:
		_on_defeated()

func _on_defeated() -> void:
	defeated.emit()
	queue_free()
