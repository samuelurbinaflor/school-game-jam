class_name Settings
extends Control

var _color_tween: Tween

signal settings_closed


func _ready() -> void:
	visible = false
	_load_last_tab()


func _load_last_tab() -> void:
	var tab_container = get_node_or_null("MarginContainer/TabContainer")
	if tab_container:
		var last_tab: int = get_node("/root/ConfigManager").get_setting("settings", "last_tab", 0)
		tab_container.current_tab = last_tab
		tab_container.tab_changed.connect(_on_tab_changed)


func _on_tab_changed(tab_index: int) -> void:
	get_node("/root/ConfigManager").set_setting("settings", "last_tab", tab_index)


func show_settings() -> void:
	visible = true
	var overlay_color = GameState.get_overlay_color()
	$"Panel".self_modulate = Color(overlay_color.r, overlay_color.g, overlay_color.b, 1.0)
	
	# Blanco Default
	if overlay_color == Color(1, 1, 1, 0):
		_animate_overlay_colors()


func _animate_overlay_colors() -> void:
	# TODO: Cambiar según los colores finales
	var colors = [
		Color.RED,
		Color.GREEN,
		Color(0.784, 0.397, 0.005),  # Orange
		Color(0.616, 0.575, 0.002),  # Yellow
	]
	
	if _color_tween:
		_color_tween.kill()
	
	_color_tween = create_tween()
	_color_tween.set_loops()
	
	for color in colors:
		_color_tween.tween_property($"Panel", "self_modulate", color, 2.0)


func _on_close_button_pressed() -> void:
	if _color_tween:
		_color_tween.kill()
	visible = false
	# Return to pause menu, don't resume game
	var gui = get_parent()
	gui.get_node("PauseMenu").show()
	settings_closed.emit()

