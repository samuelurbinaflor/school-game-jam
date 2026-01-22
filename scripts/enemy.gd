extends Area2D

enum EnemyType { RED, GREEN }
@export var enemy_type: EnemyType = EnemyType.RED

var is_corrupted = false

var normal_color: Color
var corrupted_color = Color(0.3, 0.6, 1.0) 

@onready var sprite = $Sprite2D

func _ready():
	match enemy_type:
		EnemyType.RED:
			normal_color = Color(1, 0.2, 0.2) 
		EnemyType.GREEN:
			normal_color = Color(0.2, 1, 0.2) 
	
	sprite.modulate = normal_color
	
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	print("Enemy ", name, " tipo ", EnemyType.keys()[enemy_type], " listo")

func _on_area_entered(area):
	print("Área detectada en enemy: ", area.name)
	if not is_corrupted:
		try_corrupt()

func _on_body_entered(body):
	if body.is_in_group("player") and not is_corrupted:
		try_corrupt()

func try_corrupt():
	var can_corrupt = false
	
	match enemy_type:
		EnemyType.RED:
			can_corrupt = GameState.current_mode == GameState.WorldMode.RED
		EnemyType.GREEN:
			can_corrupt = GameState.current_mode == GameState.WorldMode.GREEN
	
	if can_corrupt:
		corrupt()

func corrupt():
	is_corrupted = true
	sprite.modulate = corrupted_color
	print("Enemigo corrompido!")
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)
