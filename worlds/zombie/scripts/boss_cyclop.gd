extends "res://worlds/zombie/scripts/base_enemy.gd"

signal phase_changed(phase: int)
signal defeated

const PROJECTILE_SCENE = preload("res://worlds/zombie/scenes/boss_projectile.tscn")
const ZOMBIE_BASIC_SCENE = preload("res://worlds/zombie/scenes/zombie_basic.tscn")

## Speed used once the boss enters phase 2. Base `speed` acts as phase-1 speed.
@export var speed_phase2: float = 90.0

var max_hp: int
var phase: int = 1
var _shoot_timer: float = 0.0
var _summon_timer: float = 0.0

func _ready() -> void:
	super._ready()
	max_hp = hp
	AudioManager.bg_play_music(2.1)

func _ai_process(delta: float) -> void:
	if !player.isDead:
		_check_phase_transition()
		_handle_movement()
		_handle_shooting(delta)
		if phase == 2:
			_handle_summon(delta)

func _check_phase_transition() -> void:
	if phase == 1 and hp * 2 <= max_hp:
		phase = 2
		speed = speed_phase2
		phase_changed.emit(phase)
		if sprite:
			sprite.modulate = Color(1.8, 0.3, 0.3)

func _handle_movement() -> void:
	var dir := (player.global_position - global_position).normalized()
	velocity = dir * speed
	anim_tree.set("parameters/blend_position", dir)
	move_and_slide()
	if sprite:
		sprite.flip_h = dir.x < 0

func _handle_shooting(delta: float) -> void:
	_shoot_timer -= delta
	if _shoot_timer <= 0.0:
		_shoot_timer = 1.2 if phase == 2 else 2.5
		_fire_at_player()

func _fire_at_player() -> void:
	var count := 3 if phase == 2 else 1
	var spread := TAU / 16.0
	var base_dir := (player.global_position - global_position).normalized()
	for i in range(count):
		var angle_offset := (i - (count - 1) / 2.0) * spread
		var proj := PROJECTILE_SCENE.instantiate()
		proj.global_position = global_position
		proj.direction = base_dir.rotated(angle_offset)
		proj.damage = damage
		proj.speed = 280.0
		proj.set_meta("enemy_projectile", true)
		get_tree().current_scene.add_child(proj)

func _handle_summon(delta: float) -> void:
	_summon_timer -= delta
	if _summon_timer <= 0.0:
		_summon_timer = 5.0
		for i in range(3):
			var angle := (TAU / 3.0) * i
			var zombie := ZOMBIE_BASIC_SCENE.instantiate()
			zombie.global_position = global_position + Vector2(cos(angle), sin(angle)) * 90.0
			zombie.add_to_group("zombies")
			get_tree().current_scene.add_child(zombie)

func _update_flash(delta: float) -> void:
	_flash_timer -= delta
	if _flash_timer <= 0.0 and sprite:
		sprite.modulate = Color(1.8, 0.3, 0.3) if phase == 2 else Color.WHITE

func _on_death() -> void:
	defeated.emit()
	queue_free()
