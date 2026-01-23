extends Enemy

enum Comportamiento { MOVER, QUIETO }

@export var comportamiento: Comportamiento = Comportamiento.MOVER

@onready var ray_dere = $RayCastDere
@onready var ray_izq = $RayCastIzq
@onready var ray_dere_abajo = $RayCastAbajoDere
@onready var area_2d = $Area2D

var vel = 100
var move_left = false
var gravity = 10
var ha_girado = false

func _ready():
	super()
	
	
func _physics_process(_delta):
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
	
	if move_left:
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
	if ha_girado:
		var no_colision = true
		if move_left and ray_izq.is_colliding():
			no_colision = false
		elif not move_left and ray_dere.is_colliding():
			no_colision = false
		
		if no_colision:
			ha_girado = false
		return
			
	if not ray_dere_abajo.is_colliding():
		gira = true
	if move_left and ray_izq.is_colliding():
		gira = true
	elif not move_left and ray_dere.is_colliding():
		gira = true
	
	if gira:
		move_left = !move_left
		scale.x = -scale.x
		ha_girado = true

func _on_mode_changed(_new_mode):
	if _new_mode == GameState.WorldMode.RED:
		set_collision_mask_value(1, true)
		set_collision_mask_value(2, true)
	else:
		set_collision_mask_value(1, false)
		set_collision_mask_value(2, true)
	
	if is_corrupted:
		return

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and \
	   GameState.current_mode == GameState.WorldMode.RED and \
	   not is_corrupted:
		try_corrupt()

func get_enemy_type() -> GameState.WorldMode:
	return GameState.WorldMode.RED
