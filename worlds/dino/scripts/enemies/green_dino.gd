extends Enemy

func _ready() -> void:
	super()
	hurtbox.damage = base_damage
	velocity.x = speed
	add_to_group("enemies")

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	super(delta)
