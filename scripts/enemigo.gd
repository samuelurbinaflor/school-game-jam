extends CharacterBody2D

var vel = 100
var moveLeft = false
var gravity = 10

@onready var RayDere = $RayCastDere
@onready var RayIzq = $RayCastIzq
@onready var RayDereAbajo = $RayCastAbajoDere
#@onready var spriteAnim = $AnimatedSprite2D

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity
	else: 
		velocity.y = 0
	
	if moveLeft:
		velocity.x = -vel
	else:
		velocity.x = vel
	move_and_slide()
	vuelta()

func vuelta():
	var gira = false
	
	if not RayDereAbajo.is_colliding():
		gira = true
	
	if moveLeft and RayIzq.is_colliding():
		gira = true
	elif not moveLeft and RayDere.is_colliding():
		gira = true
	
	if gira:
		moveLeft = !moveLeft
		scale.x = -scale.x

"""
if moveLeft and not RayIzqAbajo.is_colliding():
		moveLeft = false
		scale.x = -scale.x
	elif not moveLeft and not RayDereAbajo.is_colliding():
		moveLeft = true
		scale.x = -scale.x

	if moveLeft and RayIzq.is_colliding():
		moveLeft = false
		scale.x = -scale.x
	elif not moveLeft and RayDere.is_colliding():
		moveLeft = true
		scale.x = -scale.x"""

"""if RayDere.is_colliding():
		direc = -1
		#spriteAnim.flip_h = true
	if RayIzq.is_colliding():
		direc = 1
		#spriteAnim.flip_h = false
	position.x += direc * vel * delta"""
