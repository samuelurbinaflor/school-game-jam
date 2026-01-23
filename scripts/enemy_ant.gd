extends CharacterBody2D

enum Comportamiento { MOVER, QUIETO }

@export var comportamiento: Comportamiento = Comportamiento.MOVER

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
var haGirado = false

signal corrupted

func _ready():
	GameState.mode_changed.connect(worldModeChanged)
	#sprite.modulate = normal_color
	
	
func _physics_process(delta):
	if is_corrupted:
		velocity = Vector2.ZERO
		play_anim("corrupted")
		move_and_slide()
		return
	
	if comportamiento == Comportamiento.QUIETO:
		velocity = Vector2.ZERO
		play_anim("idle")
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
	
	vuelta()
	
	# ───── ANIMACIONES ─────
	if velocity.x == 0:
		play_anim("idle")
	else:
		play_anim("walk")
		
	move_and_slide()

func vuelta():
	var gira = false
	if haGirado:
		var noColision = true
		if moveLeft and RayIzq.is_colliding():
			noColision = false
		elif not moveLeft and RayDere.is_colliding():
			noColision = false
		
		if noColision:
			haGirado = false
		return
			
	if not RayDereAbajo.is_colliding():
		gira = true
	if moveLeft and RayIzq.is_colliding():
		gira = true
	elif not moveLeft and RayDere.is_colliding():
		gira = true
	
	if gira:
		moveLeft = !moveLeft
		scale.x = -scale.x
		haGirado = true

func worldModeChanged(new_mode):
	if new_mode == GameState.WorldMode.RED:
		set_collision_mask_value(1,true)
		set_collision_mask_value(2,true)
		#collision.disabled = false
	else:
		set_collision_mask_value(1,false)
		set_collision_mask_value(2,true)
		#collision.disabled = true
		
	if is_corrupted:
		return

#func corrupt():
	#is_corrupted = true
	#animated_sprite_2d.play("corrupted")
	#sprite.modulate = corrupted_color
	#print("El enemigo ahora es azul")
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and GameState.current_mode == GameState.WorldMode.RED and not is_corrupted:
		print("El enemigo esta corrupto")
		is_corrupted = true
		set_collision_mask_value(1, false)
		corrupted.emit()
		
func play_anim(name: String):
	if animated_sprite_2d.animation != name:
		animated_sprite_2d.play(name)
