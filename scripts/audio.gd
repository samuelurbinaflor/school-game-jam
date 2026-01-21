extends VBoxContainer

var base_windows_size: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height"),
)

const CONFIG_FILE_PATH: String = "user://game_settings.cfg"
var config: ConfigFile = ConfigFile.new()

var audio_buses: Dictionary = { }
var audio_controls: Dictionary = { }
var muted_volumes: Dictionary = { }
var is_muting: bool = false


func _ready() -> void:
	_load_config()
	_init_audio_buses()
	_apply_audio_settings()


func _load_config() -> void:
	var err := config.load(CONFIG_FILE_PATH)
	if err != OK:
		print("No existing config file found, using default settings.")
	else:
		print("Config file loaded successfully.")


func _init_audio_buses() -> void:
	var bus_count: int = AudioServer.get_bus_count()
	for i in range(bus_count):
		var bus_name: String = AudioServer.get_bus_name(i)
		audio_buses[bus_name] = i

		# Try to find the bus container node
		var bus_container = get_node_or_null(bus_name + "Bus")
		if bus_container == null:
			continue

		# Find child nodes within the bus container
		var volume_slider = bus_container.get_node_or_null("Slider")
		var mute_button = bus_container.get_node_or_null("MuteButton")
		var minus_button = bus_container.get_node_or_null("MinusButton")
		var plus_button = bus_container.get_node_or_null("PlusButton")

		if volume_slider == null or mute_button == null:
			continue

		audio_controls[bus_name] = {
			"volume_slider": volume_slider,
			"mute_button": mute_button,
			"minus_button": minus_button,
			"plus_button": plus_button,
		}

		volume_slider.value_changed.connect(Callable(self, "_on_volume_changed").bind(bus_name))
		mute_button.toggled.connect(Callable(self, "_on_mute_toggled").bind(bus_name))
		if minus_button != null:
			minus_button.pressed.connect(Callable(self, "_on_minus_pressed").bind(bus_name))
		if plus_button != null:
			plus_button.pressed.connect(Callable(self, "_on_plus_pressed").bind(bus_name))
		var saved_volume: float = config.get_value("audio", bus_name + "_volume", 50.0)
		var saved_muted: bool = config.get_value("audio", bus_name + "_muted", false)
		AudioServer.set_bus_volume_db(audio_buses[bus_name], saved_volume)
		AudioServer.set_bus_mute(audio_buses[bus_name], saved_muted)
		audio_controls[bus_name]["volume_slider"].value = saved_volume
		audio_controls[bus_name]["mute_button"].button_pressed = saved_muted

		# If muted, save the volume and set slider to 0
		if saved_muted:
			muted_volumes[bus_name] = saved_volume
			audio_controls[bus_name]["volume_slider"].value = 0

		# Update the mute button icon
		_update_mute_button_icon(bus_name)


func _update_mute_button_icon(bus_name: String) -> void:
	if bus_name not in audio_controls:
		return

	var slider = audio_controls[bus_name]["volume_slider"]
	var mute_button = audio_controls[bus_name]["mute_button"]
	var value: float = slider.value

	var icon_path: String
	if value == 0:
		icon_path = "res://assets/ui/vol0.png"
	elif value <= 33.33:
		icon_path = "res://assets/ui/vol1.png"
	elif value <= 66.66:
		icon_path = "res://assets/ui/vol2.png"
	else:
		icon_path = "res://assets/ui/vol3.png"

	mute_button.icon = load(icon_path)


func _on_volume_changed(value: float, bus_name: String) -> void:
	if is_muting:
		return
	var bus_index: int = audio_buses[bus_name]
	AudioServer.set_bus_volume_db(bus_index, value)
	config.set_value("audio", bus_name + "_volume", value)
	config.save(CONFIG_FILE_PATH)
	
	# If the bus is currently muted and the value is non-zero, update the saved volume for unmute
	if bus_name in muted_volumes and value != 0:
		muted_volumes[bus_name] = value
	
	_update_mute_button_icon(bus_name)


func _on_mute_toggled(toggled_on: bool, bus_name: String) -> void:
	print("Mute toggled for %s: %s" % [bus_name, str(toggled_on)])
	var bus_index: int = audio_buses[bus_name]
	var slider = audio_controls[bus_name]["volume_slider"]
	var mute_button = audio_controls[bus_name]["mute_button"]

	is_muting = true
	
	# Disconnect the toggled signal to prevent infinite loop
	mute_button.toggled.disconnect(Callable(self, "_on_mute_toggled").bind(bus_name))

	if toggled_on:
		muted_volumes[bus_name] = slider.value
		slider.value = 0.0
		await get_tree().process_frame
		AudioServer.set_bus_volume_db(bus_index, 0)
	else:
		if bus_name in muted_volumes:
			slider.value = muted_volumes[bus_name]
			await get_tree().process_frame
			AudioServer.set_bus_volume_db(bus_index, muted_volumes[bus_name])
			muted_volumes.erase(bus_name)

	is_muting = false

	AudioServer.set_bus_mute(bus_index, toggled_on)
	config.set_value("audio", bus_name + "_muted", toggled_on)
	config.save(CONFIG_FILE_PATH)
	_update_mute_button_icon(bus_name)
	
	# Reconnect the signal
	mute_button.toggled.connect(Callable(self, "_on_mute_toggled").bind(bus_name))


func _on_minus_pressed(bus_name: String) -> void:
	if bus_name in audio_controls:
		var slider = audio_controls[bus_name]["volume_slider"]
		slider.value -= 10


func _on_plus_pressed(bus_name: String) -> void:
	if bus_name in audio_controls:
		var slider = audio_controls[bus_name]["volume_slider"]
		slider.value += 10


func _apply_audio_settings() -> void:
	for bus_name in audio_buses.keys():
		var bus_index: int = audio_buses[bus_name]
		var volume: float = config.get_value("audio", bus_name + "_volume", 0.0)
		var muted: bool = config.get_value("audio", bus_name + "_muted", false)
		AudioServer.set_bus_volume_db(bus_index, volume)
		AudioServer.set_bus_mute(bus_index, muted)


func _on_reset_button_pressed() -> void:
	for bus_name in audio_buses.keys():
		var bus_index: int = audio_buses[bus_name]
		AudioServer.set_bus_volume_db(bus_index, 50.0)
		AudioServer.set_bus_mute(bus_index, false)

		if bus_name in audio_controls:
			var slider = audio_controls[bus_name]["volume_slider"]
			var mute_button = audio_controls[bus_name]["mute_button"]
			slider.value = 50.0
			mute_button.button_pressed = false

		config.set_value("audio", bus_name + "_volume", 50.0)
		config.set_value("audio", bus_name + "_muted", false)

	config.save(CONFIG_FILE_PATH)
