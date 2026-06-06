extends CharacterBody2D

signal died(zombie)
signal hit_player(damage)

const POWERUP_SCENE = preload("res://worlds/zombie/scenes/powerup.tscn")

@export var speed: float = 60.0
@export var charge_speed: float = 180.0
@export var hp: int = 8
@export var damage: int = 2
@export var xp_value: int = 30
@export var drop_chance: float = 0.25

var player: CharacterBody2D = null
var _hit_cooldown: float = 0.0
var _flash_timer: float = 0.0
var _charge_timer: float = 4.0
var _charging: bool = false
var _charge_duration: float = 0.0
var _charge_dir: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("enemies")
	# Stagger charge timers so elites don't all rush at once
	_charge_timer = randf_range(2.0, 5.0)

func _physics_process(delta: float) -> void:
	_hit_cooldown -= delta
	_update_flash(delta)
	_charge_timer -= delta

	if player == null:
		player = _find_player()
	if player == null:
		return

	if _charging:
		_do_charge(delta)
	else:
		_do_chase(delta)

	if sprite:
		sprite.flip_h = velocity.x < 0

func _do_chase(delta: float) -> void:
	var to_player = player.global_position - global_position
	var dist = to_player.length()
	var dir = to_player / dist if dist > 0.0 else Vector2.ZERO

	var separation = _get_separation()
	var move_dir = (dir + separation * 0.35).normalized()
	velocity = move_dir * speed
	move_and_slide()

	if dist < 36.0 and _hit_cooldown <= 0.0:
		_hit_cooldown = 1.2
		hit_player.emit(damage)
		if player.has_method("take_damage"):
			player.take_damage(damage)

	# Start charge when in medium range
	if _charge_timer <= 0.0 and dist < 250.0:
		_charging = true
		_charge_duration = 0.45
		_charge_dir = dir
		_charge_timer = randf_range(4.0, 7.0)
		if sprite:
			sprite.modulate = Color(1.5, 0.5, 0.1)

func _do_charge(_delta: float) -> void:
	_charge_duration -= _delta
	velocity = _charge_dir * charge_speed
	move_and_slide()

	if global_position.distance_to(player.global_position) < 36.0 and _hit_cooldown <= 0.0:
		_hit_cooldown = 0.8
		hit_player.emit(damage * 2)
		if player.has_method("take_damage"):
			player.take_damage(damage * 2)

	if _charge_duration <= 0.0:
		_charging = false
		if sprite and _flash_timer <= 0.0:
			sprite.modulate = Color.WHITE

func _get_separation() -> Vector2:
	var sep = Vector2.ZERO
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == self:
			continue
		var d = global_position.distance_to(enemy.global_position)
		if d < 44.0 and d > 0.0:
			sep += (global_position - enemy.global_position) / d
	return sep

func _update_flash(delta: float) -> void:
	_flash_timer -= delta
	if _flash_timer <= 0.0 and sprite and not _charging:
		sprite.modulate = Color.WHITE

func _find_player() -> CharacterBody2D:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null

func take_damage(amount: int) -> void:
	hp -= amount
	_flash_timer = 0.15
	if sprite:
		sprite.modulate = Color(2.5, 0.3, 0.3)
	if hp <= 0:
		_on_death()

func _on_death() -> void:
	died.emit(self)
	if randf() < drop_chance:
		_drop_powerup()
	queue_free()

func _drop_powerup() -> void:
	var powerup = POWERUP_SCENE.instantiate()
	powerup.global_position = global_position
	get_tree().current_scene.add_child(powerup)
