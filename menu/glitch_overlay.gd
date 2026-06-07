extends ColorRect

# Overlay encima de todo — lanza glitches visuales aleatorios
@export var min_interval: float = 3.0
@export var max_interval: float = 8.0

var _timer: float = 0.0
var _next_glitch: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color = Color(0, 0, 0, 0)
	_schedule_next()

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= _next_glitch:
		_timer = 0.0
		_schedule_next()
		_trigger_glitch()

func _schedule_next() -> void:
	_next_glitch = randf_range(min_interval, max_interval)

func _trigger_glitch() -> void:
	var roll: int = randi() % 3
	match roll:
		0: _flash_green()
		1: _scanline_sweep()
		2: _color_shift()

func _flash_green() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "color", Color(0.22, 1.0, 0.08, 0.12), 0.04)
	tween.tween_property(self, "color", Color(0, 0, 0, 0), 0.04)
	tween.tween_property(self, "color", Color(0.22, 1.0, 0.08, 0.08), 0.03)
	tween.tween_property(self, "color", Color(0, 0, 0, 0), 0.06)

func _scanline_sweep() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "color", Color(0.0, 0.8, 0.1, 0.06), 0.08)
	tween.tween_property(self, "color", Color(0, 0, 0, 0), 0.12)

func _color_shift() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "color", Color(1.0, 0.0, 0.0, 0.07), 0.03)
	tween.tween_property(self, "color", Color(0.0, 0.0, 1.0, 0.07), 0.03)
	tween.tween_property(self, "color", Color(0, 0, 0, 0), 0.05)
