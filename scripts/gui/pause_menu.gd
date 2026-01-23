extends Control

@onready var gui = get_parent()


func _ready() -> void:
	$VBoxContainer/MarginContainer/VBoxContainer/ResumeButton.pressed.connect(
		_on_resume_pressed)
	$VBoxContainer/MarginContainer/VBoxContainer/ToSettingsButton.pressed.connect(
		_on_to_settings_pressed)


func _on_resume_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_to_settings_pressed() -> void:
	gui.get_node("Settings").show_settings()
	hide()
