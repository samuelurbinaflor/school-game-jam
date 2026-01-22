extends StaticBody2D

enum PlatformType { RED, ORANGE, YELLOW, GREEN }
@export var platform_type: PlatformType = PlatformType.RED

var is_active = false

var disabled_frame: int
var enabled_frame: int

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	# Configurar frames según el tipo de plataforma
	match platform_type:
		PlatformType.RED:
			enabled_frame = 0   # Rojo sólido
			disabled_frame = 4  # Rojo líneas
		PlatformType.ORANGE:
			enabled_frame = 1   # Naranja sólido
			disabled_frame = 5  # Naranja líneas
		PlatformType.GREEN:
			enabled_frame = 2   # Verde sólido
			disabled_frame = 6  # Verde líneas
		PlatformType.YELLOW:
			enabled_frame = 3   # Amarillo sólido
			disabled_frame = 7  # Amarillo líneas
	
	# Mostrar frame de líneas
	set_platform_state(false)
	
	# Conectar a los cambios de modo
	GameState.mode_changed.connect(_on_mode_changed)
	
	print("Plataforma ", name, " tipo ", PlatformType.keys()[platform_type], " lista")

func _on_mode_changed(new_mode: GameState.WorldMode):
	# Verificar el color de esta plataforma
	var should_be_active = false
	
	match platform_type:
		PlatformType.RED:
			should_be_active = (new_mode == GameState.WorldMode.RED)
		PlatformType.ORANGE:
			should_be_active = (new_mode == GameState.WorldMode.ORANGE)
		PlatformType.YELLOW:
			should_be_active = (new_mode == GameState.WorldMode.YELLOW)
		PlatformType.GREEN:
			should_be_active = (new_mode == GameState.WorldMode.GREEN)
	
	set_platform_state(should_be_active)

func set_platform_state(active: bool):
	is_active = active
	collision.set_deferred("disabled", !active)
	
	if active:
		# Plataforma habilitada
		sprite.frame = enabled_frame
		set_collision_layer_value(2, true)  # Activar en capa 2
		
		print("Plataforma ", name, " ACTIVADA - Collision disabled: ", collision.disabled)
		
		# Animación de activación
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 0.15)
		tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.15)
	else:
		# Plataforma deshabilitada
		sprite.frame = disabled_frame
		set_collision_layer_value(2, false)  # Desactivar de capa 2
		
		print("Plataforma ", name, " DESACTIVADA - Collision disabled: ", collision.disabled)
		
		# Animación de desactivación
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(0.95, 0.95), 0.1)
		tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
