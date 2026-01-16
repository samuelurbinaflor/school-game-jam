extends Area2D

@onready var sprite = $Sprite2D
var is_pressed = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	sprite.modulate = Color(0.9, 0.7, 0.5)

func _on_body_entered(body):
	if body.name == "Player" and not is_pressed:
		activate()

func _on_body_exited(body):
	if body.name == "Player":
		is_pressed = false

func activate():
	is_pressed = true
	GameState.switch_mode()
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(0.9, 0.8), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	
	match GameState.current_mode:
		GameState.WorldMode.NORMAL:
			sprite.modulate = Color(0.9, 0.7, 0.5)
		GameState.WorldMode.RED:
			sprite.modulate = Color(1, 0.5, 0.5)
		GameState.WorldMode.GREEN:
			sprite.modulate = Color(0.5, 1, 0.5)
