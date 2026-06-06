class_name Player
extends CharacterBody2D

@onready var coyote_time: Timer = $PlayerMovement/CoyoteTime
@onready var jump_buffer: Timer = $PlayerMovement/JumpBuffer
@onready var kb_timer: Timer = $PlayerMovement/KBTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var death_timer: Timer = $DeathTimer
@onready var movement_component = $PlayerMovement
@onready var animation_component = $PlayerAnimation
@onready var attackbox = $AttackBox

var recoil := Vector2.ZERO
#var isAttacking: bool = false
var isHurt: bool = false
var isDead: bool = false
var kb_dir: int

@export var hp: float
@export var base_damage: float
@export var self_recoil_force: float
@export var recoil_force: float
@export var recoil_stop: float

func _ready():
	Global.player = self
	animation_component.sprite.texture = Ref.PlayerSheet
	add_to_group("player")

func _process(delta: float):
	movement_component._process(delta)
	animation_component._process(delta)
	
	if Input.is_action_just_pressed("attack") && attack_timer.is_stopped():
		attackbox.monitoring = true
		attackbox.visible = true
		attack_timer.start()

func _physics_process(delta: float):
	movement_component._physics_process(delta)
	recoil = recoil.move_toward(Vector2.ZERO, recoil_stop * delta)
	velocity += recoil
	move_and_slide()

func hurt(damage: float):
	isHurt = true
	hp -= damage;
	#print("HP: ", hp)
	if(hp <= 0.0):
		kill()

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
