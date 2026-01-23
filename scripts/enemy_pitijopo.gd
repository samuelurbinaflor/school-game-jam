extends CharacterBody2D

@onready var RayDere = $RayCastDere
@onready var RayIzq = $RayCastIzq
#@onready var RayDereAbajo = $RayCastAbajoDere
@onready var sprite: Sprite2D = $Sprite2D
@onready var detectaArea2D: Area2D = $Area2D

var vel = 120
var moveRight = true
var moveDown = true
var time = 0.0
var is_corrupted = false
var posicion = Vector2.ZERO
var normal_color: Color = Color(0.104, 0.626, 0.228, 1.0)
var corrupted_color = Color(0.3, 0.6, 1.0) 
var gravity = 500

signal corrupted

enum patronVuelo { float, horizontal, vertical, circle }
@export var vuelo: patronVuelo = patronVuelo.horizontal
@export var distanciaV = 50 #distancia max v
@export var distanciaH = 100 #distancia max h
@export var Rcirculo = 50
@export var velCirculo = 1

func _ready():
	GameState.mode_changed.connect(worldModeChanged)
	sprite.modulate = normal_color
	posicion = global_position
	
	#if detectaArea2D:
	#	detectaArea2D.body_entered.connect(_on_area_2d_body_entered)
	#	detectaArea2D.area_entered.connect(_on_area_2d_area_entered)
	
func _physics_process(delta):
	time += delta
	if is_corrupted:
		velocity.y += gravity * delta
		velocity.x = 0
		#velocity = Vector2.ZERO
		move_and_slide()
		return
	
	match vuelo:
		patronVuelo.float:
			fly_float(delta)
		patronVuelo.horizontal:
			fly_horizontal(delta)
		patronVuelo.vertical:
			fly_vertical(delta)
		#patronVuelo.circle:
			#fly_circle(delta)
	move_and_slide()

func fly_float(delta): #solo para flotar en el mismo sitio
	var offset = sin(time * 2.0) * 20.0
	global_position.y = posicion.y + offset
	velocity = Vector2.ZERO

func fly_horizontal(delta): #mov horizontal con rebote 
	#calcular distancia desde punto inicial
	var distanciaInicio = global_position.x - posicion.x
	
	if distanciaInicio >= distanciaH: #límites de distancia
		moveRight = false #limite derecho
		sprite.flip_h = true
	elif distanciaInicio <= -distanciaH:
		moveRight = true #limite izq
		sprite.flip_h = false
	
	#colisiones con raycasts por si hay paredes :3
	if moveRight and RayDere and RayDere.is_colliding():
		moveRight = false
		sprite.flip_h = true
	elif not moveRight and RayIzq and RayIzq.is_colliding():
		moveRight = true
		sprite.flip_h = false
	
	if moveRight:
		velocity.x = vel
	else:
		velocity.x = -vel
	
	#flotar suave
	var float_offset = sin(time * 3.0) * 10.0
	velocity.y = float_offset

func fly_vertical(delta): #mov vertical
	var distanciaInicio = global_position.y - posicion.y
	
	if distanciaInicio >= distanciaV:
		moveDown = false
	elif distanciaInicio <= -distanciaV:
		moveDown = true
	
	if moveDown:
		velocity.y = vel
	else:
		velocity.y = -vel
	
	var float_offset = sin(time * 2.0) * 5.0
	velocity.x = float_offset

#func fly_circle(delta): #mov circular
	#var x_offset = cos(time * velCirculo) * Rcirculo
	#var y_offset = sin(time * velCirculo) * Rcirculo
	#global_position = posicion + Vector2(x_offset, y_offset)
	#velocity = Vector2.ZERO

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_corrupted:
		corrupt()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not is_corrupted:
		corrupt()

func corrupt():
	if GameState.current_mode == GameState.WorldMode.GREEN:
		is_corrupted = true
		sprite.modulate = corrupted_color
		print("Pitijopo corrompido?")
		corrupted.emit()
		
		set_collision_mask_value(1,false)
		#if collision:
			#collision.set_deferred("disabled", true)
	
	#pequeña animacion
	#var tween = create_tween()
	#tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.2)
	#tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)

func worldModeChanged(new_mode):
	if is_corrupted:
		return
	if new_mode == GameState.WorldMode.GREEN:
		set_collision_mask_value(1,true)
		set_collision_mask_value(2,true)
	else:
		set_collision_mask_value(1,false)
		set_collision_mask_value(2,true)
		
	if not is_corrupted and new_mode != GameState.WorldMode.GREEN:
		sprite.modulate = normal_color
