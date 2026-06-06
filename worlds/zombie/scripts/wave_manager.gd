extends Node

signal wave_started(wave_number)
signal wave_completed(wave_number)
signal boss_spawned
signal all_completed
signal score_changed(score)
signal kills_updated(kills, target)

enum State { WAITING, SPAWNING, WAVE_ACTIVE, WAVE_COMPLETE, BOSS_PHASE, VICTORY }

const ZOMBIE_BASIC_SCENE = preload("res://worlds/zombie/scenes/zombie_basic.tscn")
const ZOMBIE_ELITE_SCENE = preload("res://worlds/zombie/scenes/zombie_elite.tscn")
const BOSS_SCENE = preload("res://worlds/zombie/scenes/boss_cyclop.tscn")

@export var arena_half_width: float = 400.0
@export var arena_half_height: float = 280.0
@export var spawn_interval: float = 2.0

var current_wave: int = 0
var kills: int = 0
var score: int = 0
var kills_per_wave: Array[int] = [15, 25, 40]
var total_waves: int = 3
var state: State = State.WAITING
var _spawn_timer: float = 0.0
var _wave_start_delay: float = 3.0
var _delay_timer: float = 0.0

var spawn_points: Array[Marker2D] = []

func _ready() -> void:
	_delay_timer = 2.0

func _physics_process(delta: float) -> void:
	match state:
		State.WAITING:
			_delay_timer -= delta
			if _delay_timer <= 0.0:
				_start_next_wave()
		State.WAVE_ACTIVE:
			_spawn_timer -= delta
			if _spawn_timer <= 0.0:
				_spawn_timer = spawn_interval
				_spawn_zombie()
		State.WAVE_COMPLETE:
			_delay_timer -= delta
			if _delay_timer <= 0.0:
				if current_wave >= total_waves:
					_start_boss()
				else:
					state = State.WAITING
					_delay_timer = _wave_start_delay

func _start_next_wave() -> void:
	current_wave += 1
	kills = 0
	state = State.WAVE_ACTIVE
	_spawn_timer = 0.5
	wave_started.emit(current_wave)

func _spawn_zombie() -> void:
	var pos = _get_spawn_position()
	var elite_chance = 0.1 + (current_wave - 1) * 0.15
	var scene = ZOMBIE_ELITE_SCENE if randf() < elite_chance else ZOMBIE_BASIC_SCENE
	var zombie = scene.instantiate()
	zombie.global_position = pos
	zombie.died.connect(_on_zombie_died)
	get_tree().current_scene.add_child(zombie)

func _get_spawn_position() -> Vector2:
	var side = randi() % 4
	var center = Vector2.ZERO
	var scene_root = get_tree().current_scene
	if scene_root.has_node("Player"):
		center = scene_root.get_node("Player").global_position
	match side:
		0:
			return Vector2(randf_range(-arena_half_width, arena_half_width), -arena_half_height) + center
		1:
			return Vector2(randf_range(-arena_half_width, arena_half_width), arena_half_height) + center
		2:
			return Vector2(-arena_half_width, randf_range(-arena_half_height, arena_half_height)) + center
		3:
			return Vector2(arena_half_width, randf_range(-arena_half_height, arena_half_height)) + center
	return Vector2.ZERO

func _on_zombie_died(zombie) -> void:
	kills += 1
	var xp = zombie.xp_value if "xp_value" in zombie else 10
	score += xp
	score_changed.emit(score)

	var target = kills_per_wave[current_wave - 1] if current_wave <= kills_per_wave.size() else kills_per_wave[-1]
	kills_updated.emit(kills, target)

	if kills >= target and state == State.WAVE_ACTIVE:
		state = State.WAVE_COMPLETE
		_delay_timer = _wave_start_delay
		wave_completed.emit(current_wave)

func deduct_score(amount: int) -> void:
	score = max(0, score - amount * 50)
	score_changed.emit(score)

func _start_boss() -> void:
	state = State.BOSS_PHASE
	var boss = BOSS_SCENE.instantiate()
	boss.global_position = Vector2(arena_half_width * 0.5, -arena_half_height * 0.5)
	boss.defeated.connect(_on_boss_defeated)
	get_tree().current_scene.add_child(boss)
	boss_spawned.emit()

func _on_boss_defeated() -> void:
	score += 200
	score_changed.emit(score)
	state = State.VICTORY
	all_completed.emit()
