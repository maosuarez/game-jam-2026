extends "res://worlds/zombie/scripts/base_zombie.gd"

@export var charge_speed: float = 180.0

var _charge_timer: float = 4.0
var _charging: bool = false
var _charge_duration: float = 0.0
var _charge_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	super._ready()
	_charge_timer = randf_range(2.0, 5.0)

func _ai_process(delta: float) -> void:
	_charge_timer -= delta
	if _charging:
		_do_charge(delta)
	else:
		_do_chase(delta)
	if sprite:
		sprite.flip_h = velocity.x < 0

func _do_chase(_delta: float) -> void:
	var to_player := player.global_position - global_position
	var dist := to_player.length()
	var dir := to_player / dist if dist > 0.0 else Vector2.ZERO

	var move_dir := (dir + _get_separation() * 0.35).normalized()
	velocity = move_dir * speed
	move_and_slide()

	if _charge_timer <= 0.0 and dist < 250.0:
		_charging = true
		_charge_duration = 0.45
		_charge_dir = dir
		_charge_timer = randf_range(4.0, 7.0)
		if sprite:
			sprite.modulate = Color(1.5, 0.5, 0.1)

func _do_charge(delta: float) -> void:
	_charge_duration -= delta
	velocity = _charge_dir * charge_speed
	move_and_slide()

	if _charge_duration <= 0.0:
		_charging = false
		if sprite and _flash_timer <= 0.0:
			sprite.modulate = Color.WHITE

func _update_flash(delta: float) -> void:
	_flash_timer -= delta
	if _flash_timer <= 0.0 and sprite and not _charging:
		sprite.modulate = Color.WHITE
