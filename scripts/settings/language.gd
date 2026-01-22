extends Node

const CONFIG_FILE_PATH: String = "user://game_settings.cfg"
var config: ConfigFile = ConfigFile.new()


func _enter_tree() -> void:
	_load_language_preference()


func _ready() -> void:
	var option_button = get_node_or_null("MarginContainer/OptionButton")
	if option_button:
		var current_locale = TranslationServer.get_locale()
		if current_locale.begins_with("es"):
			option_button.select(1)
		else:
			option_button.select(0)
		option_button.item_selected.connect(_on_language_option_button_item_selected)


func _load_language_preference() -> void:
	var locale: String = "en"

	if OS.get_name() == "Web":
		locale = _load_language_from_localstorage()
	else:
		locale = _load_config()

	TranslationServer.set_locale(locale)


func _load_config() -> String:
	var err := config.load(CONFIG_FILE_PATH)
	if err != OK:
		print("No existing config file found, using default settings.")
		return "en"
	else:
		print("Config file loaded successfully.")
		return config.get_value("language", "locale", "en")


func _load_language_from_localstorage() -> String:
	if OS.get_name() == "Web":
		var result = JavaScriptBridge.eval("localStorage.getItem('game_language') || 'en'")
		return result if result else "en"
	return "en"



func change_language(index: int) -> void:
	var locale: String = ""
	match index:
		0:
			locale = "en"
		1:
			locale = "es"

	if locale != "":
		TranslationServer.set_locale(locale)
		_save_language_preference(locale)


func _save_language_preference(locale: String) -> void:
	if OS.get_name() == "Web":
		_save_language_to_localstorage(locale)
	else:
		_save_language_to_configfile(locale)


func _save_language_to_configfile(locale: String) -> void:
	config.set_value("language", "locale", locale)
	config.save(CONFIG_FILE_PATH)


func _save_language_to_localstorage(locale: String) -> void:
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("localStorage.setItem('game_language', '" + locale + "')")


func _on_language_option_button_item_selected(index: int) -> void:
	change_language(index)
