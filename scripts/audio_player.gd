extends AudioStreamPlayer

# Preload all audio files
const CLICK_SFX = preload("res://assets/audio/sfx/ui/bubble_avance.mp3")
const BACK_SFX = preload("res://assets/audio/sfx/ui/bubble_retroceso.mp3")

# Dictionary of available sounds
var ui_sounds = {
	"click": CLICK_SFX,
	"back": BACK_SFX
}

var vel_fade: float = 1.0
var fade: bool = false


func _ready():
	bus = "Music"


func play_music(music: AudioStream, vol: float = -10.0) -> void:
	if stream == music:
		return
	stream = music
	volume_db = vol
	play()


func music_fade(music: AudioStream, vol: float = -10.0) -> void:
	if stream == music:
		return
	stream = music
	volume_db = -70.0
	play()
	var tween = create_tween()
	tween.tween_property(self, "volume_db", vol, vel_fade)


func stop_music() -> void:
	if fade:
		return
	fade = true
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80.0, vel_fade)
	tween.tween_callback(
		func():
			stop()
			volume_db = 0.0
			fade = false
	)


func play_ui_sound(sound_key: String = "click") -> void:
	if sound_key not in ui_sounds:
		push_error("Sound not found: " + sound_key)
		return
	play_sfx(ui_sounds[sound_key], -15.0)


func click_btn() -> void:
	play_ui_sound("click")


func back_btn() -> void:
	play_ui_sound("back")


func play_sfx(audio_stream: AudioStream, vol: float = 0.0) -> void:
	var sfx = AudioStreamPlayer.new()
	sfx.stream = audio_stream
	sfx.volume_db = vol
	sfx.bus = "UI"
	add_child(sfx)
	sfx.play()
	
	await sfx.finished
	sfx.queue_free()
