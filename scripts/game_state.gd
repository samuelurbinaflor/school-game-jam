extends Node

enum WorldMode { NORMAL, RED, ORANGE, YELLOW, GREEN }

var current_mode: WorldMode = WorldMode.NORMAL

signal mode_changed(new_mode: WorldMode)

func switch_mode(new_mode: WorldMode):
	if current_mode == new_mode:
		current_mode = WorldMode.NORMAL
	else:
		current_mode = new_mode
	mode_changed.emit(current_mode)
	
	match current_mode:
		WorldMode.NORMAL:
			current_mode = WorldMode.NORMAL
		WorldMode.RED:
			current_mode = WorldMode.RED
		WorldMode.GREEN:
			current_mode = WorldMode.GREEN
		WorldMode.ORANGE:
			current_mode = WorldMode.ORANGE
		WorldMode.YELLOW:
			current_mode = WorldMode.YELLOW
	
	mode_changed.emit(current_mode)
	print("Modo cambiado a: ", WorldMode.keys()[current_mode])

func reset_to_normal():
	current_mode = WorldMode.NORMAL
	mode_changed.emit(current_mode)
	print("Game state resetted to NORMAL")

func reset_counter():
	# Get the GUI node and reset the counter
	var gui = get_tree().root.find_child("GameHud", true, false)
	if gui:
		gui.corrupted_count = 1
		gui._update_mushroom_counter()
		print("Counter resetted to 1")

func get_overlay_color() -> Color:
	match current_mode:
		WorldMode.RED:
			return Color(1, 0, 0, 0.2) 
		WorldMode.GREEN:
			return Color(0, 1, 0, 0.2)  
		WorldMode.ORANGE:
			return Color(0.784, 0.397, 0.005, 0.2)
		WorldMode.YELLOW:
			return Color(0.616, 0.575, 0.002, 0.2)
		_:
			return Color(1, 1, 1, 0)   
