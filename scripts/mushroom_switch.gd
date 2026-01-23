extends Area2D

@export var switch_type: GameState.WorldMode = GameState.WorldMode.RED

@onready var sprite = $Sprite2D
@onready var switch_audio: AudioStreamPlayer2D = $MushroomAudioPlayer
var is_pressed := false

# Audio streams
const ACTIVATE_SOUND = preload("res://assets/audio/sfx/spores.mp3")


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_color(switch_type)


func _on_body_entered(body):
	if body.name == "Player" and not is_pressed:
		activate()


func _on_body_exited(body):
	if body.name == "Player":
		is_pressed = false


func activate():
	is_pressed = true
	GameState.switch_mode(switch_type)
	play_sound(ACTIVATE_SOUND)

	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(0.9, 0.8), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)


func play_sound(stream: AudioStream) -> void:
	if switch_audio:
		switch_audio.stream = stream
		switch_audio.play()


func _update_color(mode: GameState.WorldMode):
	match mode:
		GameState.WorldMode.NORMAL:
			sprite.modulate = Color.BLACK
		GameState.WorldMode.RED:
			sprite.modulate = Color(0.614, 0.0, 0.131)
		GameState.WorldMode.ORANGE:
			sprite.modulate = Color(0.765, 0.397, 0.044)
		GameState.WorldMode.YELLOW:
			sprite.modulate = Color(0.607, 0.578, 0.037)
		GameState.WorldMode.GREEN:
			sprite.modulate = Color(0.0, 0.61, 0.225)
