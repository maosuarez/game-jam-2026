class_name PauseMenu
extends CanvasLayer

signal resumed
signal quit_to_hub

@onready var overlay: ColorRect = $Overlay
@onready var dialog_box: PanelContainer = $DialogBox
@onready var character_sprite: AnimatedSprite2D = $DialogBox/HBox/CharacterPanel/CharacterSprite
@onready var resume_btn: Button = $DialogBox/HBox/MenuContent/ResumeButton
@onready var settings_btn: Button = $DialogBox/HBox/MenuContent/SettingsButton
@onready var quit_btn: Button = $DialogBox/HBox/MenuContent/QuitButton

func _ready() -> void:
	hide()
	resume_btn.pressed.connect(_on_resume)
	settings_btn.pressed.connect(_on_settings)
	quit_btn.pressed.connect(_on_quit)

func open() -> void:
	get_tree().paused = true
	show()
	if character_sprite.sprite_frames and character_sprite.sprite_frames.has_animation("idle"):
		character_sprite.play("idle")

func close() -> void:
	get_tree().paused = false
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_on_resume()

func _on_resume() -> void:
	close()
	resumed.emit()

func _on_settings() -> void:
	pass  # TODO: abrir panel de opciones

func _on_quit() -> void:
	close()
	quit_to_hub.emit()
