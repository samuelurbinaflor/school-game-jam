extends Node

func _ready() -> void:
	print("GUI _ready() called")
	$Settings.hide()
	$PauseButton.hide()

	# Listen for scene changes
	get_tree().scene_changed.connect(_on_scene_changed)

	# Check if level is already loaded (in case gui loads after level)
	_check_and_start_timer()


func _on_scene_changed() -> void:
	print("Scene changed, checking for level...")
	_check_and_start_timer()


func _check_and_start_timer() -> void:
	# Wait a frame to ensure scene is fully loaded
	await get_tree().process_frame

	if has_level_scene():
		print("Level scene found!")
		$PauseButton.show()
		start_timer()


func has_level_scene() -> bool:
	# Check for common level scene names or any scene that's not GUI-related
	var root = get_tree().root
	print("Root children: ", root.get_children().map(func(c): return c.name))
	for child in root.get_children():
		# Check if it's a level scene (contains Player, enemies, etc.)
		print("Checking child: ", child.name)
		if child.name.contains("level") or child.has_node("Player"):
			print("Found level scene: ", child.name)
			return true
	return false


func start_timer() -> void:
	# Try to find TimeProgress in the tree
	var time_progress = get_tree().root.find_child("TimeProgress", true, false)
	print("Looking for TimeProgress...")
	if time_progress:
		print("Timer started!")
		time_progress.start()
	else:
		print("TimeProgress node not found in the tree")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pausa") and has_level_scene(): 
		toggle_pause()
		get_tree().root.set_input_as_handled()


func toggle_pause() -> void:
	if get_tree().paused:
		_on_resume_pressed()
	else:
		_on_pause_button_pressed()


func _on_pause_button_pressed() -> void:
	$PauseMenu.show()
	get_tree().paused = true


func _on_resume_pressed() -> void:
	$PauseMenu.hide()
	get_tree().paused = false
