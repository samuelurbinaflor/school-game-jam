extends CharacterBody2D

@onready var RayDere = $RayCastDere
@onready var RayIzq = $RayCastIzq
@onready var RayDereAbajo = $RayCastAbajoDere
@onready var area2D = $Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

var vel = 100
var moveLeft = false
var gravity = 10
var is_corrupted = false
var normal_color: Color = Color(0.808, 0.0, 0.0, 1.0)
var corrupted_color = Color(0.3, 0.6, 1.0) 
var haGirado = false
<<<<<<< Updated upstream
<<<<<<< Updated upstream
=======

enum Mood {idle, walk}
var mood = Mood.walk
var timeMood = 0
@export var minMood = 2.0 #tiempos para la duracion del modo en el que estara la hormiga (andar o idle)
@export var maxMood = 5.0
var normalMood = 3.0
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

enum Mood {idle, walk}
var mood = Mood.walk
var timeMood = 0
@export var minMood = 2.0 #tiempos para la duracion del modo en el que estara la hormiga (andar o idle)
@export var maxMood = 5.0
var normalMood = 3.0

func _ready():
	GameState.mode_changed.connect(worldModeChanged)
	randomize()
	normalMood = randf_range(minMood, maxMood)
	#sprite.modulate = normal_color
	
func _physics_process(delta):
	if is_corrupted:
		velocity = Vector2.ZERO
		play_anim("corrupted")
		move_and_slide()
		return

	timeMood += delta
	if timeMood >= normalMood:
		cambiaMood()
		timeMood = 0.0
	
	if not is_on_floor():
		velocity.y += gravity
	else: 
		velocity.y = 0

	if mood == Mood.walk:
		if moveLeft:
			velocity.x = -vel
		else:
			velocity.x = vel
		move_and_slide()
		vuelta()
	else:
		velocity.x = 0
	
	# ───── ANIMACIONES ─────
	if velocity.x == 0:
		play_anim("idle")
	else:
		play_anim("walk")

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
	#updateCollision()
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
		print("El enemigo esta corrupto")
		#corrupt()
		is_corrupted = true
		animated_sprite_2d.play("corrupted")
		
		if collision:
			collision.set_deferred("disabled", true)
		
func play_anim(name: String):
	if animated_sprite_2d.animation != name:
		animated_sprite_2d.play(name)

func cambiaMood():
	if mood == Mood.idle:
		mood = Mood.walk
	else:
		mood = Mood.idle
	normalMood = randf_range(minMood, maxMood)
	print("La hormiga cambió a: ", mood)
