extends Node2D

@onready var overlay = $CanvasLayer/ColorRect

func _ready():
	GameState.mode_changed.connect(_on_mode_changed)
	
	_on_mode_changed(GameState.current_mode)

func _on_mode_changed(_new_mode):
	var tween = create_tween()
	tween.tween_property(overlay, "color", GameState.get_overlay_color(), 0.3)
