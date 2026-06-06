class_name Player
extends CharacterBody2D

@onready var coyote_time: Timer = $PlayerMovement/CoyoteTime
@onready var jump_buffer: Timer = $PlayerMovement/JumpBuffer
@onready var kb_timer: Timer = $PlayerMovement/KBTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var death_timer: Timer = $DeathTimer
@onready var charge_timer: Timer = $ChargeTimer
@onready var movement_component = $PlayerMovement
@onready var animation_component = $PlayerAnimation
@onready var attackbox = $AttackBox
@onready var glitch_ray_spawn = $GlitchRaySpawn
@onready var glitch_ray_scene: PackedScene = Ref.GlitchRayScene
@onready var charge_bar = $PlayerUI/MarginContainer/ChargeBar
@onready var camera = $Camera2D

var recoil := Vector2.ZERO
var isAttacking: bool = false
var isHurt: bool = false
var isDead: bool = false
var kb_dir: int

@export var hp: float
@export var max_hp: float
@export var base_damage: float
@export var self_recoil_force: float
@export var recoil_force: float
@export var recoil_stop: float

func _ready():
	Global.player = self
	hp = max_hp
	animation_component.sprite.texture = Ref.PlayerSheets["dino"]
	charge_bar.max_value = charge_timer.wait_time
	add_to_group("player")

func _process(delta: float):
	movement_component._process(delta)
	animation_component._process(delta)
	
	if !charge_timer.is_stopped():
		charge_bar.value = charge_timer.wait_time - charge_timer.time_left
	
	if Input.is_action_just_pressed("attack") && attack_timer.is_stopped():
		attackbox.monitoring = true
		attackbox.visible = true
		attack_timer.start()
	if Input.is_action_just_pressed("glitch_ray"):
		charge_timer.start()
		charge_bar.visible = true
		animation_component.animation_player.play("shoot")
		isAttacking = true
	if Input.is_action_just_released("glitch_ray"):
		isAttacking = false
		animation_component.sprite.texture = Ref.PlayerSheets["dino"]
		animation_component.animation_player.play(movement_component.state_machine.current_state.name)
		if charge_timer.is_stopped():
			shoot_glitch_ray()
		else:
			charge_timer.stop()
			charge_timer.timeout.emit()

func _physics_process(delta: float):
	movement_component._physics_process(delta)
	recoil = recoil.move_toward(Vector2.ZERO, recoil_stop * delta)
	velocity += recoil
	move_and_slide()

func shoot_glitch_ray():
	var glitch_ray = glitch_ray_scene.instantiate()
	glitch_ray.global_position = glitch_ray_spawn.global_position
	glitch_ray.direction = -1.0 if animation_component.sprite.flip_h else 1.0
	get_tree().current_scene.add_child(glitch_ray)
	if randf() < 0.3:
		animation_component.sprite.texture = Ref.PlayerSheets["normal"]
		await get_tree().create_timer(randf_range(0.02, 0.15)).timeout
		animation_component.sprite.texture = Ref.PlayerSheets["dino"]
		await get_tree().create_timer(randf_range(0.02, 0.15)).timeout
		animation_component.sprite.texture = Ref.PlayerSheets["normal"]
		await get_tree().create_timer(randf_range(0.02, 0.15)).timeout
		animation_component.sprite.texture = Ref.PlayerSheets["dino"]

func hurt(damage: float):
	isHurt = true
	hp -= damage;
	print("HP: ", hp)
	if(hp <= 0.0):
		kill()
	else:
		animation_component.hit_flash()

func heal(healing: float):
	hp += healing;
	if(hp > max_hp):
		hp = max_hp
	print("HP: ", hp)

func kill():
	isDead = true
	Engine.time_scale = 0.5
	death_timer.start()

func apply_recoil(direction: Vector2, force: float):
	recoil = direction * force

func _on_death_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://worlds/dino/scenes/game.tscn")

func _on_attack_timer_timeout() -> void:
	attackbox.monitoring = false
	attackbox.visible = false

func _on_attack_box_area_entered(area: Area2D) -> void:
	pass

func _on_attack_box_body_entered(body: Node2D) -> void:
	if(body.is_in_group("enemies")):
		if body.isDead: return
		var dir = sign(global_position.x - body.global_position.x)
		
		apply_recoil(Vector2(dir, 0.0), self_recoil_force)
		body.apply_recoil(Vector2(-dir, 0.0), recoil_force)
		body.hurt(base_damage)


func _on_charge_timer_timeout() -> void:
	charge_bar.visible = false
	charge_bar.value = 0.0
