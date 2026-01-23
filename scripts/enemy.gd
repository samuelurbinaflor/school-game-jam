extends CharacterBody2D

class_name Enemy

var is_corrupted = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

signal corrupted

const POP_SOUND = preload("res://assets/audio/sfx/rising-bubbly-pop-351023.mp3")


func _ready():
	GameState.mode_changed.connect(_on_mode_changed)


func try_corrupt():
	var can_corrupt = false

	match get_enemy_type():
		GameState.WorldMode.RED:
			can_corrupt = GameState.current_mode == GameState.WorldMode.RED
		GameState.WorldMode.GREEN:
			can_corrupt = GameState.current_mode == GameState.WorldMode.GREEN

	if can_corrupt:
		corrupt()


func corrupt():
	is_corrupted = true
	print("Enemy corrupted!")
	
	# Reproducir sonido usando call_deferred para evitar problemas con callbacks de física
	call_deferred("_play_pop_sound")
	
	corrupted.emit()


func _play_pop_sound():
	var pop_audio = AudioStreamPlayer2D.new()
	pop_audio.stream = POP_SOUND
	add_child(pop_audio)
	pop_audio.play()


func play_anim(anim_name: String):
	if animated_sprite_2d and animated_sprite_2d.animation != anim_name:
		animated_sprite_2d.play(anim_name)


func _on_mode_changed(_new_mode):
	# Override in child classes if needed
	pass


func get_enemy_type() -> GameState.WorldMode:
	# Override in child classes to return RED or GREEN
	return GameState.WorldMode.RED
