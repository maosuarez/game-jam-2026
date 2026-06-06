extends Area2D

@export var speed: float = 400.0
@export var damage: int = 1

var direction: Vector2 = Vector2.ZERO
var _lifetime: float = 3.0
var _is_enemy_projectile: bool = false

func _ready() -> void:
	_is_enemy_projectile = get_meta("enemy_projectile", false)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		rotation = direction.angle()
	global_position += direction * speed * delta
	_lifetime -= delta
	if _lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if _is_enemy_projectile:
		if body.is_in_group("player") or body.has_method("take_damage") and not body.is_in_group("enemies"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
			queue_free()
	else:
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()

func _on_area_entered(area: Node) -> void:
	if _is_enemy_projectile:
		if area.is_in_group("player_hitbox"):
			var parent = area.get_parent()
			if parent.has_method("take_damage"):
				parent.take_damage(damage)
			queue_free()
	else:
		# Hits walls
		pass
