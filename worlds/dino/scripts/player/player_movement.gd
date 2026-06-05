extends Node2D

@export var player: Player
@onready var state_machine = $state_machine

func _ready():
	state_machine.player = player
	state_machine.init()

func _process(delta: float):
	state_machine._process(delta)

func _physics_process(delta: float):
	state_machine._physics_process(delta)
