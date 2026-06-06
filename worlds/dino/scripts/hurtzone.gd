class_name HurtZone
extends Area2D

var damage: float = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	#print(body)
	if(body.is_in_group("player") && !Global.player.isHurt && !Global.player.isDead):
		Global.player.kb_dir = sign(body.global_position.x - global_position.x)
		body.hurt(damage)
