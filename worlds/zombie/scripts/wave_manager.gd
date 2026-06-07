extends Node

signal wave_started(wave_number)
signal wave_completed(wave_number)
signal boss_spawned
signal all_completed
signal score_changed(score)
signal kills_updated(kills, target)

enum State { WAITING, SPAWNING, WAVE_ACTIVE, WAVE_COMPLETE, BOSS_PHASE, VICTORY, DEFEAT }

const ZOMBIE_BASIC_SCENE = preload("res://worlds/zombie/scenes/zombie_basic.tscn")
const ZOMBIE_ELITE_SCENE = preload("res://worlds/zombie/scenes/zombie_elite.tscn")
const BOSS_SCENE = preload("res://worlds/zombie/scenes/boss_cyclop.tscn")
const PORTAL_SCENE = preload("res://worlds/zombie/scenes/portal.tscn")

@export var arena_half_width: float = 400.0
@export var arena_half_height: float = 280.0
@export var spawn_interval: float = 2.0
## Mínima distancia del jugador al borde del arena para bloquear ese lado de spawn.
@export var edge_margin: float = 80.0
@export var map_min: Vector2 = Vector2(-415, -287)
@export var map_max: Vector2 = Vector2(415, 287)

@export var current_wave: int = 0
var kills: int = 0
var score: int = 0
var kills_per_wave: Array[int] = [15, 25, 40]
#var kills_per_wave: Array[int] = [1, 1, 1]
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
				_start_boss()
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

func stop() -> void:
	state = State.DEFEAT

func _start_next_wave() -> void:
	current_wave += 1
	if current_wave == 1: 
		AudioManager.bg_play_music(2.0)
	kills = 0
	state = State.WAVE_ACTIVE
	_spawn_timer = 0.5
	spawn_interval = 2.0 / current_wave
	wave_started.emit(current_wave)

func _spawn_zombie() -> void:
	var pos = _get_spawn_position()
	var elite_chance = 0.1 + (current_wave - 1) * 0.15
	var scene = ZOMBIE_ELITE_SCENE if randf() < elite_chance else ZOMBIE_BASIC_SCENE
	var zombie = scene.instantiate()
	zombie.global_position = pos
	zombie.died.connect(_on_zombie_died)
	zombie.add_to_group("zombies")
	get_tree().current_scene.add_child(zombie)

func _get_spawn_position() -> Vector2:
	var player_pos := Vector2.ZERO
	var scene_root = get_tree().current_scene
	if scene_root.has_node("Player"):
		player_pos = scene_root.get_node("Player").global_position
	
	var available: Array[int] = []
	if player_pos.y + arena_half_height > edge_margin:
		available.append(0)
	if arena_half_height - player_pos.y > edge_margin:
		available.append(1)
	if player_pos.x + arena_half_width > edge_margin:
		available.append(2)
	if arena_half_width - player_pos.x > edge_margin:
		available.append(3)
	
	if available.is_empty():
		available = [0, 1, 2, 3]
	
	# Intenta hasta 10 veces encontrar una posición dentro del mapa
	for attempt in range(10):
		var side := available[randi() % available.size()]
		var pos: Vector2
		match side:
			0: pos = Vector2(randf_range(-arena_half_width, arena_half_width), -arena_half_height) + player_pos
			1: pos = Vector2(randf_range(-arena_half_width, arena_half_width), arena_half_height) + player_pos
			2: pos = Vector2(-arena_half_width, randf_range(-arena_half_height, arena_half_height)) + player_pos
			3: pos = Vector2(arena_half_width, randf_range(-arena_half_height, arena_half_height)) + player_pos
		
		# Verifica que esté dentro del mapa
		if _is_within_map(pos):
			return pos
	
	# Si no encontró ninguna válida, spawnea en el centro
	return Vector2.ZERO

func _is_within_map(pos: Vector2) -> bool:
	return pos.x >= map_min.x and pos.x <= map_max.x and pos.y >= map_min.y and pos.y <= map_max.y

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
		clear_remaining_zombies()

func clear_remaining_zombies() -> void:
	for zombie in get_tree().get_nodes_in_group("zombies"):
		zombie.call_deferred("queue_free")
	for proj in get_tree().get_nodes_in_group("enemy_projectile"):
		proj.call_deferred("queue_free")

func deduct_score(amount: int) -> void:
	score = max(0, score - amount * 50)
	score_changed.emit(score)

func _start_boss() -> void:
	boss_spawned.emit()
	state = State.BOSS_PHASE
	for i in range(3):
		Global.level.boss_alert.visible = true;
		await get_tree().create_timer(0.5).timeout
		Global.level.boss_alert.visible = false;
		await get_tree().create_timer(0.5).timeout
		print(i)
	var boss = BOSS_SCENE.instantiate()
	boss.global_position = Global.level.glitch_trigger.global_position
	boss.defeated.connect(_on_boss_defeated)
	get_tree().current_scene.add_child(boss)

func _on_boss_defeated(pos: Vector2) -> void:
	clear_remaining_zombies()
	var portal = PORTAL_SCENE.instantiate()
	portal.global_position = pos
	get_tree().current_scene.add_child(portal)
	score += 200
	score_changed.emit(score)
	state = State.VICTORY
	all_completed.emit()
