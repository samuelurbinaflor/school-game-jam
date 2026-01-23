extends Control

@onready var gui = get_parent()
var just_paused = false


func _ready() -> void:
	var resume_button = $VBoxContainer/MarginContainer/VBoxContainer/ResumeButton
	var settings_button = $VBoxContainer/MarginContainer/VBoxContainer/ToSettingsButton
	
	if not resume_button.pressed.is_connected(_on_resume_pressed):
		resume_button.pressed.connect(_on_resume_pressed)
	
	if not settings_button.pressed.is_connected(_on_to_settings_button_pressed):
		settings_button.pressed.connect(_on_to_settings_button_pressed)
	
	if not gui.get_node("Settings").settings_closed.is_connected(_on_settings_closed):
		gui.get_node("Settings").settings_closed.connect(_on_settings_closed)


func _input(event: InputEvent) -> void:
	# Si el PauseMenu está visible y presionas pausa sin Settings ni Alert visibles
	if visible and event.is_action_pressed("pausa") and not just_paused:
		var alert = get_node_or_null("Alert")
		if not gui.get_node("Settings").visible and (not alert or not alert.visible):
			_on_resume_pressed()
			get_tree().root.set_input_as_handled()
	
	# Resetear just_paused en el siguiente frame
	just_paused = false


func _on_settings_closed() -> void:
	show()


func _on_to_settings_button_pressed() -> void:
	gui.get_node("Settings").show_settings()
	hide()


func _on_to_menu_button_pressed() -> void:
	get_tree().paused = false
	GameState.reset_to_normal()
	GameState.reset_counter()
	hide()
	gui.get_node("PauseButton").hide()
	gui.get_node("MushroomCounter").hide()
	%TimeProgress.hide()
	var alert = get_node_or_null("Alert")
	if alert:
		alert.hide()
	get_tree().change_scene_to_file("res://scenes/gui/main_menu.tscn")


func _on_to_alert_pressed() -> void:
	var alert = get_node_or_null("Alert")
	if alert:
		alert.show()
	else:
		print("Alert node not found in PauseMenu")


func _on_close_alert_button_pressed() -> void:
	$Alert.hide()


func _on_resume_pressed() -> void:
	get_tree().paused = false
	hide()
