extends Node

var streamPlayers = {}

func create_stream_player(spKey: String, busName: String) -> void:
	streamPlayers[spKey] = AudioStreamPlayer.new()
	streamPlayers[spKey].bus = busName
	add_child(streamPlayers[spKey])

func _ready():
	create_stream_player("BGMusic", "BGMusic")


func bg_play_music(level: float):
	var sp: AudioStreamPlayer = streamPlayers["BGMusic"]
	sp.stream = load(Ref.BG_Music[level])
	sp.volume_db = -15.0
	sp.play(2.7)
