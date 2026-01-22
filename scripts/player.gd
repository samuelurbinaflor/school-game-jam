extends CharacterBody2D

const vel = 200.0
const jumpVel = -600.0 #era constante
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("salto") and is_on_floor():
		velocity.y = jumpVel

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
	if not is_on_floor():
		animated_sprite_2d.play("jump")
	elif direc == 0:
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("walk")
