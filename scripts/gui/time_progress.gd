class_name TimeProgress
extends TextureProgressBar

@export var total_time: float = 120.0 # Time in seconds

var _time_remaining: float = 0.0
var _is_running: bool = false


func _ready() -> void:
	max_value = total_time
	value = 0.0
	_time_remaining = total_time
	_update_color()

	visible = false

	GameState.mode_changed.connect(_on_gamestate_mode_changed)


func _physics_process(delta: float) -> void:
	if _is_running:
		_time_remaining -= delta

		if _time_remaining <= 0.0:
			_time_remaining = 0.0
			_is_running = false
			time_finished.emit()

		value = total_time - _time_remaining


func start() -> void:
	visible = true
	_is_running = true
	_time_remaining = total_time
	value = 0.0


func stop() -> void:
	_is_running = false


func reset() -> void:
	_time_remaining = total_time
	value = 0.0
	_is_running = false


func get_time_remaining() -> float:
	return _time_remaining


func _update_color() -> void:
	var overlay_color = GameState.get_overlay_color()
	modulate = Color(overlay_color.r, overlay_color.g, overlay_color.b, 1.0)


func _on_gamestate_mode_changed(_new_mode: int) -> void:
	_update_color()


signal time_finished
