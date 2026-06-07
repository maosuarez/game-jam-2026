extends CharacterBody2D

# Definicion de Las variables importantes.
@export var speed: float = 80.0
@export var hp: int = 3
@export var damage: int = 1
@export var xp_value: int = 10
@export var separation_radius: float = 40.0
@export var hit_flash_color: Color = Color(2.5, 2.5, 2.5, 1.0)
@export var hit_flash_duration: float = 0.15

# Cargar el Jugador 
var player: CharacterBody2D = null
var _flash_timer: float = 0.0
var max_hp: int

# Sprite Base
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_tree = $Sprite2D/AnimationTree

# Cuando inicia lo agregamos al grupo de los enemigos.
func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 2 # El esta en la capa 2, para colisionar con el caracter principal
	collision_mask = 1
	max_hp = hp

# Procesamiento de Fisica
func _physics_process(delta: float) -> void:
	_update_flash(delta)
	if player == null:
		player = _find_player()
	if player == null:
		return
	_ai_process(delta)

## Override in subclasses to implement movement/attack behaviour.
func _ai_process(_delta: float) -> void:
	pass

# Busca el Player como objeto ara poder seguirlo
func _find_player() -> CharacterBody2D:
	var players := get_tree().get_nodes_in_group("player")
	return players[0] if players.size() > 0 else null

func _get_separation() -> Vector2:
	var sep := Vector2.ZERO
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == self:
			continue
		var d := global_position.distance_to(enemy.global_position)
		if d < separation_radius and d > 0.0:
			sep += (global_position - enemy.global_position) / d
	return sep

func _update_flash(delta: float) -> void:
	_flash_timer -= delta
	if _flash_timer <= 0.0 and sprite:
		sprite.modulate = Color.WHITE

func take_damage(amount: int) -> void:
	hp -= amount
	_flash_timer = hit_flash_duration
	if sprite:
		sprite.modulate = hit_flash_color
	if hp <= 0:
		_on_death()

## Override in subclasses to customise death behaviour (drops, signals, etc.).
func _on_death() -> void:
	queue_free()
