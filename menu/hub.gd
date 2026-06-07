extends Control

const WORLD_SCENES = {
	"FolderDino":   "res://worlds/dino/scenes/main.tscn",
	"FolderZombie": "res://worlds/zombie/scenes/main.tscn",
	"FolderPuzzle": "res://worlds/puzzle/scenes/main.tscn",
	"FolderMix":    "res://worlds/mix/scenes/main.tscn",
}

var unlocked: Dictionary = {
	"FolderDino":   true,
	"FolderZombie": true,
	"FolderPuzzle": true,
	"FolderMix":    false,
}

@onready var clock: Label                 = $Taskbar/TaskbarRow/Clock
@onready var character: AnimatedSprite2D  = $Character
@onready var shadow: Node2D               = $CharacterShadow
@onready var file_grid: GridContainer     = $FileBrowserWindow/WindowLayout/FileArea/FileGrid

var _is_moving: bool = false

func _ready() -> void:
	_connect_folders()
	$Taskbar/TaskbarRow/StartBtn.pressed.connect(_on_start_pressed)
	_apply_unlock_states()
	character.play("idle")

func _process(_delta: float) -> void:
	clock.text = Time.get_time_string_from_system().substr(0, 5)
	# Sombra sigue al personaje en X
	if shadow:
		shadow.position.x = character.position.x

func _connect_folders() -> void:
	for folder_name in WORLD_SCENES.keys():
		var folder: Control = file_grid.get_node_or_null(folder_name)
		if folder == null:
			continue
		folder.gui_input.connect(_on_folder_input.bind(folder_name))
		folder.mouse_entered.connect(_on_folder_hover.bind(folder_name))
		folder.mouse_exited.connect(_on_folder_exit.bind(folder_name))

func _apply_unlock_states() -> void:
	var mix: Control = file_grid.get_node_or_null("FolderMix")
	if mix:
		mix.modulate = Color(0.4, 0.4, 0.4, 1.0)

func _on_folder_input(event: InputEvent, folder_name: String) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.double_click:
		_open_world(folder_name)

func _on_folder_hover(folder_name: String) -> void:
	var folder: Control = file_grid.get_node_or_null(folder_name)
	if folder == null:
		return
	var icon: TextureRect = folder.get_node_or_null("Icon")
	if icon:
		var tw: Tween = create_tween()
		tw.tween_property(icon, "scale", Vector2(1.15, 1.15), 0.12).set_ease(Tween.EASE_OUT)
	if unlocked.get(folder_name, false):
		folder.modulate = Color(0.75, 1.0, 0.75, 1.0)
	_move_character_to_folder(folder_name)

func _on_folder_exit(folder_name: String) -> void:
	var folder: Control = file_grid.get_node_or_null(folder_name)
	if folder == null:
		return
	var icon: TextureRect = folder.get_node_or_null("Icon")
	if icon:
		var tw: Tween = create_tween()
		tw.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.1).set_ease(Tween.EASE_IN)
	if unlocked.get(folder_name, false):
		folder.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if not _is_moving:
		character.play("idle")

func _move_character_to_folder(folder_name: String) -> void:
	var folder: Control = file_grid.get_node_or_null(folder_name)
	if folder == null:
		return
	var target_x: float = folder.global_position.x + folder.size.x * 0.5
	character.flip_h = target_x < character.position.x
	_is_moving = true
	character.play("walk")
	var tw: Tween = create_tween()
	tw.tween_property(character, "position:x", target_x, 0.28) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_callback(func():
		_is_moving = false
		character.flip_h = false
		if unlocked.get(folder_name, false):
			character.play("react")
		else:
			character.play("idle")
	)

func _open_world(folder_name: String) -> void:
	if not unlocked.get(folder_name, false):
		_trigger_locked_glitch(folder_name)
		return
	character.play("look_up")
	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func(): get_tree().change_scene_to_file(WORLD_SCENES[folder_name]))

func _trigger_locked_glitch(folder_name: String) -> void:
	var folder: Control = file_grid.get_node_or_null(folder_name)
	if folder == null:
		return
	character.play("idle")
	var tw: Tween = create_tween()
	tw.tween_property(folder, "position:x", folder.position.x + 6.0, 0.04)
	tw.tween_property(folder, "position:x", folder.position.x - 6.0, 0.04)
	tw.tween_property(folder, "position:x", folder.position.x + 4.0, 0.03)
	tw.tween_property(folder, "position:x", folder.position.x, 0.03)

func _on_start_pressed() -> void:
	pass
