extends CharacterBody2D

const vel = 200.0
const jumpVel = -600.0 #era constante
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#@onready var spriteAnim = $AnimatedSprite2D

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

"""	if direc > 0:
		spriteAnim.flip_h = false
	elif direc < 0:
		spriteAnim.flip_h = true"""
	
"""	#para "controlar" las animaciones
	if is_on_floor():
		if direc == 0:
			spriteAnim.play("idle")
		else:
			spriteAnim.play("corre")
	else:
		spriteAnim.play("salta")"""
