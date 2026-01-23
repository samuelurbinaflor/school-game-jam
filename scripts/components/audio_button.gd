class_name AudioButton
extends Button

@export_enum("click", "back") var sound: String = "click"


func _ready():
	pressed.connect(_on_pressed)


func _on_pressed():
	AudioPlayer.play_ui_sound(sound)
