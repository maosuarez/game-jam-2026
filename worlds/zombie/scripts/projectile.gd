extends Area2D

@export var speed: float = 400.0
@export var damage: int = 1

var direction: Vector2 = Vector2.ZERO
var _lifetime: float = 3.0
var _is_enemy_projectile: bool = false

func _ready() -> void:
	_is_enemy_projectile = get_meta("enemy_projectile", false)
	if _is_enemy_projectile:
		collision_mask = 1  # impacta al jugador (capa 1)
	else:
		collision_mask = 2  # impacta a enemigos (capa 2)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		rotation = direction.angle()
	global_position += direction * speed * delta
	_lifetime -= delta
	if _lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if _is_enemy_projectile:
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()
	else:
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()
