extends CharacterBody2D

const vel = 200.0
const jumpVel = -400.0 #era constante
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_zone: Area2D = $"../DeathZone"

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
	else:
		if velocity.y < 0:
			play_anim("jump")
		else:
			play_anim("fall")


		
		
func play_anim(name: String):
	if animated_sprite_2d.animation != name:
		animated_sprite_2d.play(name)


func _on_death_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().reload_current_scene()
