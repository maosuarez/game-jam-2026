extends Node

enum Mode { METROIDVANIA, TOPDOWN }

var current_mode: Mode = Mode.METROIDVANIA
signal mode_changed(new_mode: Mode)

func set_mode(new_mode: Mode):
	#print(new_mode)
	if new_mode == current_mode:
		return
	current_mode = new_mode
	mode_changed.emit(new_mode)
