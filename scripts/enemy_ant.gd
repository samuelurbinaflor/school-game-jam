extends CharacterBody2D

@onready var RayDere = $RayCastDere
@onready var RayIzq = $RayCastIzq
@onready var RayDereAbajo = $RayCastAbajoDere
@onready var area2D = $Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var vel = 100
var moveLeft = false
var gravity = 10
var is_corrupted = false
var normal_color: Color = Color(0.808, 0.0, 0.0, 1.0)
var corrupted_color = Color(0.3, 0.6, 1.0) 

func _ready():
	GameState.mode_changed.connect(worldModeChanged)
	#sprite.modulate = normal_color
	
	
func _physics_process(delta):
	if is_corrupted:
		velocity = Vector2.ZERO
		play_anim("corrupted")
		move_and_slide()
		return
		
	#if GameState.current_mode == GameState.WorldMode.RED:
	#	velocity = Vector2.ZERO
	#	move_and_slide()
	#	return
	
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
	
	# ───── ANIMACIONES ─────
	if velocity.x == 0:
		play_anim("idle")
	else:
		play_anim("walk")
		

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

func worldModeChanged(new_mode):
	if is_corrupted:
		return

	#if new_mode != GameState.WorldMode.RED:
		#sprite.modulate = normal_color

#func corrupt():
	#is_corrupted = true
	#animated_sprite_2d.play("corrupted")
	#sprite.modulate = corrupted_color
	#print("El enemigo ahora es azul")
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and GameState.current_mode == GameState.WorldMode.RED and not is_corrupted:
		print("El enemigo ahora esta corrupto")
		#corrupt()
		is_corrupted = true
		animated_sprite_2d.play("corrupted")
		
func play_anim(name: String):
	if animated_sprite_2d.animation != name:
		animated_sprite_2d.play(name)
