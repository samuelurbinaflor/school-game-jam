extends Node

enum WorldMode { NORMAL, RED, GREEN }

var current_mode = WorldMode.NORMAL

signal mode_changed(new_mode)

func switch_mode():
	match current_mode:
		WorldMode.NORMAL:
			current_mode = WorldMode.RED
		WorldMode.RED:
			current_mode = WorldMode.GREEN
		WorldMode.GREEN:
			current_mode = WorldMode.NORMAL
	
	mode_changed.emit(current_mode)
	print("Modo cambiado a: ", WorldMode.keys()[current_mode])

func get_overlay_color() -> Color:
	match current_mode:
		WorldMode.RED:
			return Color(1, 0, 0, 0.3) 
		WorldMode.GREEN:
			return Color(0, 1, 0, 0.3)  
		_:
			return Color(1, 1, 1, 0)   
