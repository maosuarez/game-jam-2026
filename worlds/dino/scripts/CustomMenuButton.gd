class_name CustomMenuButton
extends TextureButton

var base_scale: Vector2
var startpos: Vector2
@export var canUpdatePivot: bool = true
@export var hover_scale_multiplier: float = 1.25

func _ready() -> void:
	action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	base_scale = scale
	startpos = position
	
	resized.connect(_update_pivot)
	_update_pivot()

func _update_pivot():
	if !canUpdatePivot: return
	pivot_offset = size / 2
	position = startpos + size / 2

func _process(delta: float) -> void:
	pass

func _on_pressed():
	#print("presionao")
	pass

func _on_mouse_entered():
	#print("entered")
	var t = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.set_ignore_time_scale(true)
	t.tween_property(self, "scale", base_scale*hover_scale_multiplier, 0.15).set_trans(Tween.TRANS_BACK)

func _on_mouse_exited():
	#print("exited")
	var t = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.set_ignore_time_scale(true)
	t.tween_property(self, "scale", base_scale, 0.15).set_trans(Tween.TRANS_BACK)
