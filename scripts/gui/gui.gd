extends Node

var corrupted_count = 9

func _ready() -> void:
	print("GUI _ready() called")
	$Settings.hide()
	$PauseButton.hide()
	$MushroomCounter.hide()
	_update_mushroom_counter()

	# Listen for scene changes
	get_tree().scene_changed.connect(_on_scene_changed)

	# Check if level is already loaded (in case gui loads after level)
	_check_and_start_timer()


func _on_scene_changed() -> void:
	print("Scene changed, checking for level...")
	_update_mushroom_counter()
	_check_and_start_timer()


func _check_and_start_timer() -> void:
	# Wait a frame to ensure scene is fully loaded
	await get_tree().process_frame

	if has_level_scene():
		print("Level scene found!")
		_connect_enemy_signals()
		$PauseButton.show()
		$MushroomCounter.show()
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

func _connect_enemy_signals() -> void:
	var root = get_tree().root
	for child in root.get_children():
		if child.name.contains("level") or child.has_node("Player"):
			_connect_enemies_in_scene(child)

func _connect_enemies_in_scene(node: Node) -> void:
	var enemies = node.find_children("*", "Node", true)
	print("Found ", enemies.size(), " total children")
	for enemy in enemies:
		# Check if it has the corrupted signal
		if enemy.has_signal("corrupted"):
			print("Connecting to: ", enemy.name)
			enemy.corrupted.connect(_on_enemy_corrupted)
		elif enemy.is_in_group("enemies") or "enemy" in enemy.name.to_lower():
			print("Found potential enemy but no signal: ", enemy.name)

func _on_enemy_corrupted() -> void:
	corrupted_count -= 1
	print("Enemy corrupted signal received!")
	_update_mushroom_counter()
	
	# Si llegamos a 0, cambiar a escena de créditos
	if corrupted_count <= 0:
		print("All enemies corrupted! Going to credits...")
		_hide_and_stop_ui()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/gui/credits.tscn")

func _update_mushroom_counter() -> void:
	var label = $MushroomCounter/Label
	label.text = "%d" % corrupted_count

func start_timer() -> void:
	# Try to find TimeProgress in the tree
	var time_progress = get_tree().root.find_child("TimeProgress", true, false)
	print("Looking for TimeProgress...")
	if time_progress:
		print("Timer started!")
		time_progress.time_finished.connect(_on_time_finished)
		time_progress.start()
	else:
		print("TimeProgress node not found in the tree")


func _on_time_finished() -> void:
	_hide_and_stop_ui()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _hide_and_stop_ui() -> void:
	# Esconder contador
	$MushroomCounter.hide()
	
	# Esconder y parar temporizador
	var time_progress = get_tree().root.find_child("TimeProgress", true, false)
	if time_progress:
		time_progress.stop()
		time_progress.hide()
	get_tree().reload_current_scene()


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
