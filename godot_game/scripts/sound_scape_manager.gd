class_name AmbienceManager extends ScriptNode
## Script responsible for controling the ambient soundscape.

const SETTING_KEY = "Ambience"

var placeholder = "empty"
var soundscape = [load("res://sound_effects/yippee.wav"), load("res://sound_effects/tap.wav")]

signal finished_loading()

## Custom streamplayer class, that loops audio by default.
class AmbientSound extends AudioStreamPlayer:
	
	func _init(loop: bool = true) -> void:
		self.autoplay = true
		if loop:
			self.connect("finished", _on_finished)

	func _on_finished() -> void:
		#await get_tree().create_timer(1).timeout # Wait 1 second before looping again.
		self.play()


func _ready() -> void:
	# Once loading is finished then load the scoundscape.
	finished_loading.connect(load_soundscape)


func load_soundscape() -> void:
	for sound in soundscape:
		add_sound_node(sound)
	print(placeholder) # <- just checking save/loading


## Create a [param AmbientSound] with the passed audio file.
func add_sound_node(sound: AudioStream) -> void:
	var sound_node = AmbientSound.new()
	sound_node.stream = sound
	add_child(sound_node)


func save() -> Dictionary:
	return {"section": Globals.AUDIO_SECTION, SETTING_KEY: "placeholder"}


func load(data) -> void:
	if data.has(SETTING_KEY):
		self.placeholder = data[SETTING_KEY]
	finished_loading.emit()
