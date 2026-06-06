extends CanvasLayer

@onready var kills_bar: ProgressBar = $KillsBar
@onready var wave_label: Label = $WaveLabel
@onready var hp_container: HBoxContainer = $HPContainer
@onready var game_over_label: Label = $GameOverLabel
@onready var wave_announce: Label = $WaveAnnounce
@onready var boss_label: Label = $BossLabel

var score_label: Label = null
var max_hp: int = 5

func _ready() -> void:
	if game_over_label:
		game_over_label.visible = false
	if wave_announce:
		wave_announce.visible = false
	if boss_label:
		boss_label.visible = false
	score_label = get_node_or_null("ScoreLabel")

func setup(player: Node, wave_manager: Node) -> void:
	if player:
		player.hp_changed.connect(_on_hp_changed)
		player.died.connect(_on_player_died)
		max_hp = player.max_hp
		_refresh_hearts(player.max_hp)

	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.wave_completed.connect(_on_wave_completed)
		wave_manager.boss_spawned.connect(_on_boss_spawned)
		wave_manager.score_changed.connect(_on_score_changed)
		wave_manager.kills_updated.connect(update_kills)
		if kills_bar:
			kills_bar.min_value = 0
	_on_score_changed(0)

func _on_hp_changed(new_hp: int) -> void:
	_refresh_hearts(new_hp)

func _refresh_hearts(current_hp: int) -> void:
	if hp_container == null:
		return
	for child in hp_container.get_children():
		child.queue_free()
	for i in range(max_hp):
		var heart = ColorRect.new()
		heart.custom_minimum_size = Vector2(20, 20)
		heart.color = Color(0.8, 0.1, 0.1) if i < current_hp else Color(0.3, 0.3, 0.3)
		hp_container.add_child(heart)

func _on_wave_started(wave_number: int) -> void:
	if wave_label:
		wave_label.text = "Wave %d / 3" % wave_number
	if kills_bar:
		kills_bar.value = 0
	if wave_announce:
		wave_announce.text = "WAVE %d" % wave_number
		wave_announce.visible = true
		await get_tree().create_timer(2.0).timeout
		if wave_announce:
			wave_announce.visible = false

func _on_wave_completed(wave_number: int) -> void:
	if wave_announce:
		wave_announce.text = "WAVE %d COMPLETE!" % wave_number
		wave_announce.visible = true
		await get_tree().create_timer(2.0).timeout
		if wave_announce:
			wave_announce.visible = false

func _on_boss_spawned() -> void:
	if wave_label:
		wave_label.text = "BOSS FIGHT!"
	if boss_label:
		boss_label.visible = true
		await get_tree().create_timer(3.0).timeout
		if boss_label:
			boss_label.visible = false

func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % new_score

func update_kills(kills: int, target: int) -> void:
	if kills_bar:
		kills_bar.max_value = target
		kills_bar.value = kills

func _on_player_died() -> void:
	if game_over_label:
		game_over_label.text = "GAME OVER\nPress R to restart"
		game_over_label.visible = true
