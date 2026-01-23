@tool
extends Area2D

# El setter permite que al cambiar el valor en el inspector, el sprite cambie al instante
@export var switch_type: GameState.WorldMode = GameState.WorldMode.RED:
	set(value):
		switch_type = value
		if Engine.is_editor_hint() or is_inside_tree():
			_update_sprite_frame()

@onready var sprite = $Sprite2D
var is_pressed := false

func _ready():
	# Solo conectamos señales si estamos jugando, no en el editor 
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)
	
	_update_sprite_frame()

func _on_body_entered(body):
	if body.name == "Player" and not is_pressed:
		activate()

func _on_body_exited(body):
	if body.name == "Player":
		is_pressed = false

func activate():
	is_pressed = true
	GameState.switch_mode(switch_type)

	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(0.9, 0.8), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)

# Esta función gestiona el cambio visual usando los frames de la imagen
func _update_sprite_frame():
	if not sprite:
		sprite = get_node_or_null("Sprite2D")
		if not sprite:
			return
	
	# Asignamos el frame según el enum de GameState
	# Orden en el sprite: Rojo, Naranja, Verde, Amarillo
	match switch_type:
		GameState.WorldMode.RED:
			sprite.frame = 0
		GameState.WorldMode.ORANGE:
			sprite.frame = 1
		GameState.WorldMode.GREEN:
			sprite.frame = 2
		GameState.WorldMode.YELLOW:
			sprite.frame = 3
		_:
			sprite.frame = 0
	
	# Asegurarnos de que el sprite use el color original
	sprite.modulate = Color.WHITE
