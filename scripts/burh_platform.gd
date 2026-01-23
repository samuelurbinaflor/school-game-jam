extends StaticBody2D

@export var segment_texture: Texture2D:
	set(value):
		segment_texture = value
		_update_texture()

@export var auto_adjust_collision: bool = true

func _ready():
	add_to_group("Burh_platform")
	_update_texture()

func _update_texture():
	if not is_inside_tree():
		return
	
	var sprite = get_node_or_null("Sprite2D")
	if sprite and segment_texture:
		sprite.texture = segment_texture
		
		if auto_adjust_collision:
			_adjust_collision_size()

func _adjust_collision_size():
	var sprite = get_node_or_null("Sprite2D")
	var collision = get_node_or_null("CollisionShape2D")
	
	if sprite and collision and segment_texture:
		var texture_size = segment_texture.get_size()
		
		if collision.shape is RectangleShape2D:
			collision.shape.size = texture_size
