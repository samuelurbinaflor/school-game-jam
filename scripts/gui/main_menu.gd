extends Control



func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_01.tscn")


func _on_settings_button_pressed() -> void:
	var settings_scene = load("res://scenes/gui/settings.tscn")
	if settings_scene:
		var settings_instance = settings_scene.instantiate()
		add_child(settings_instance)
		settings_instance.show_settings()


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gui/credits.tscn")
