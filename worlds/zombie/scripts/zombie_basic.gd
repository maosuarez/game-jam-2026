extends CharacterBody2D

signal died(zombie)
signal hit_player(damage)

const POWERUP_SCENE = preload("res://worlds/zombie/scenes/powerup.tscn")

@export var speed: float = 80.0
@export var hp: int = 3
@export var damage: int = 1
@export var xp_value: int = 10
@export var drop_chance: float = 0.10

var player: CharacterBody2D = null
var _hit_cooldown: float = 0.0
var _flash_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	_hit_cooldown -= delta
	_update_flash(delta)

	if player == null:
		player = _find_player()
	if player == null:
		return

	var to_player = player.global_position - global_position
	var dist = to_player.length()
	var dir = to_player / dist if dist > 0.0 else Vector2.ZERO

	var separation = _get_separation()
	var move_dir = (dir + separation * 0.4).normalized()
	velocity = move_dir * speed
	move_and_slide()

	if sprite:
		sprite.flip_h = move_dir.x < 0

	if dist < 32.0 and _hit_cooldown <= 0.0:
		_hit_cooldown = 1.0
		hit_player.emit(damage)
		if player.has_method("take_damage"):
			player.take_damage(damage)

func _get_separation() -> Vector2:
	var sep = Vector2.ZERO
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == self:
			continue
		var d = global_position.distance_to(enemy.global_position)
		if d < 40.0 and d > 0.0:
			sep += (global_position - enemy.global_position) / d
	return sep

func _update_flash(delta: float) -> void:
	_flash_timer -= delta
	if _flash_timer <= 0.0 and sprite:
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
