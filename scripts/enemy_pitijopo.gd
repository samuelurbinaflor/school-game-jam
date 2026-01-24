extends Enemy

@onready var ray_dere = $RayCastDere
@onready var ray_izq = $RayCastIzq
@onready var detecta_area_2d: Area2D = $Area2D

var vel = 120
var move_right = true
var move_down = true
var time = 0.0
var posicion = Vector2.ZERO
var gravity = 500

enum PatronVuelo { FLOAT, HORIZONTAL, VERTICAL, CIRCLE }
@export var vuelo: PatronVuelo = PatronVuelo.HORIZONTAL
@export var distancia_v = 50 #distancia max v
@export var distancia_h = 100 #distancia max h
@export var r_circulo = 50
@export var vel_circulo = 1

func _ready():
	super()
	posicion = global_position
	
func _physics_process(_delta):
	time += _delta
	if is_corrupted:
		set_collision_mask_value(1, false)
		set_collision_mask_value(2, true)
		velocity.y += gravity * _delta
		velocity.x = 0
		play_anim("corrupted")
		
		move_and_slide()
		return
	
	match vuelo:
		PatronVuelo.FLOAT:
			fly_float(_delta)
		PatronVuelo.HORIZONTAL:
			fly_horizontal(_delta)
		PatronVuelo.VERTICAL:
			fly_vertical(_delta)
	
	if vuelo == PatronVuelo.FLOAT:
		play_anim("idle")
	else:
		play_anim("fly")
	
	move_and_slide()

func fly_float(_delta): #solo para flotar en el mismo sitio
	var offset = sin(time * 2.0) * 20.0
	global_position.y = posicion.y + offset
	velocity = Vector2.ZERO

func fly_horizontal(_delta): #mov horizontal con rebote 
	#calcular distancia desde punto inicial
	var distancia_inicio = global_position.x - posicion.x
	
	if distancia_inicio >= distancia_h: #límites de distancia
		move_right = false #limite derecho
		animated_sprite_2d.flip_h = true
	elif distancia_inicio <= -distancia_h:
		move_right = true #limite izq
		animated_sprite_2d.flip_h = false
	
	#colisiones con raycasts por si hay paredes :3
	if move_right and ray_dere and ray_dere.is_colliding():
		move_right = false
		animated_sprite_2d.flip_h = true
	elif not move_right and ray_izq and ray_izq.is_colliding():
		move_right = true
		animated_sprite_2d.flip_h = false
	
	if move_right:
		velocity.x = vel
	else:
		velocity.x = -vel
	
	#flotar suave
	var float_offset = sin(time * 3.0) * 10.0
	velocity.y = float_offset

func fly_vertical(_delta): #mov vertical
	var distancia_inicio = global_position.y - posicion.y
	
	if distancia_inicio >= distancia_v:
		move_down = false
	elif distancia_inicio <= -distancia_v:
		move_down = true
	
	if move_down:
		velocity.y = vel
	else:
		velocity.y = -vel
	
	var float_offset = sin(time * 2.0) * 5.0
	velocity.x = float_offset

#func fly_circle(delta): #mov circular
	#var x_offset = cos(time * vel_circulo) * r_circulo
	#var y_offset = sin(time * vel_circulo) * r_circulo
	#global_position = posicion + Vector2(x_offset, y_offset)
	#velocity = Vector2.ZERO

func _on_mode_changed(_new_mode):
	if is_corrupted:
		return
	if _new_mode == GameState.WorldMode.GREEN:
		set_collision_mask_value(1, true)
		set_collision_mask_value(2, true)
	else:
		set_collision_mask_value(1, false)
		set_collision_mask_value(2, true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and \
	   GameState.current_mode == GameState.WorldMode.GREEN and \
	   not is_corrupted:
		try_corrupt()

func get_enemy_type() -> GameState.WorldMode:
	return GameState.WorldMode.GREEN
