class_name Enemy
extends Node2D

@export var hp: float
@export var base_damage: float

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func hurt(damage: float):
	hp -= damage
	print("HP: ", hp, " ", self)
	if(hp <= 0.0):
		kill()

func kill():
	self.queue_free()
