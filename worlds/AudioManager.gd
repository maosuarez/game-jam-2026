extends Node

var streamPlayers = {}

func create_stream_player(spKey: String, busName: String) -> void:
	streamPlayers[spKey] = AudioStreamPlayer.new()
	streamPlayers[spKey].bus = busName
	add_child(streamPlayers[spKey])

func _ready():
	create_stream_player("bgMusic", "BGMusic")


func bg_play_music(level: int):
	var sp: AudioStreamPlayer = streamPlayers["bgMusic"]
	sp.stream = load(Ref.BG_Music[level])
	sp.volume_db = -15.0
	sp.play(2.7)
