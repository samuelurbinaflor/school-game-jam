extends CharacterBody2D

const vel = 200.0
const jumpVel = -400.0 #era constante
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_zone: Area2D = $"../DeathZone"
@onready var player_audio: AudioStreamPlayer2D = $PlayerAudio

# Audio streams
const JUMP_SOUND = preload("res://assets/audio/sfx/movement/jump.mp3")
const FOOTSTEP_SOUND = preload("res://assets/audio/sfx/movement/walk.mp3")

var _current_anim: String = ""
var _footstep_cooldown: float = 0.0
const FOOTSTEP_INTERVAL: float = 0.4 # Tiempo entre pasitos

#Jump buffer
var jump_buffer_time := 0.12 # segundos que se guarda el input
var jump_buffer := 0.0


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	#if Input.is_action_just_pressed("salto") and is_on_floor():
	#velocity.y = jumpVel

	# ───── JUMP BUFFER ─────
	if Input.is_action_just_pressed("salto"):
		jump_buffer = jump_buffer_time
	else:
		jump_buffer -= delta

	if jump_buffer > 0 and is_on_floor():
		velocity.y = jumpVel
		jump_buffer = 0
		play_anim("jump")
		play_sound(JUMP_SOUND)

	var direc = Input.get_axis("moverIzq", "moverDere")
	if direc:
		velocity.x = direc * vel
	else:
		velocity.x = move_toward(velocity.x, 0, vel)
	move_and_slide()

	# ───── GIRAR SPRITE ─────
	if direc > 0:
		animated_sprite_2d.flip_h = false
	elif direc < 0:
		animated_sprite_2d.flip_h = true

	# ───── ANIMACIONES ─────
	if is_on_floor():
		if direc == 0:
			play_anim("idle")
		else:
			play_anim("walk")
			_update_footstep_sound(delta)
	else:
		if velocity.y < 0:
			play_anim("jump")
		else:
			play_anim("fall")
	_footstep_cooldown -= delta


func play_anim(anim_name: String):
	if animated_sprite_2d.animation != anim_name:
		_current_anim = anim_name
		animated_sprite_2d.play(anim_name)


func play_sound(stream: AudioStream) -> void:
	if player_audio:
		player_audio.stream = stream
		player_audio.play()


func _update_footstep_sound(_delta: float) -> void:
	# Play footstep sound at intervals while walking
	if _footstep_cooldown <= 0.0:
		play_sound(FOOTSTEP_SOUND)
		_footstep_cooldown = FOOTSTEP_INTERVAL


func _on_death_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().reload_current_scene()
