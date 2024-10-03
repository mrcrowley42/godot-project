class_name AmbienceManager extends ScriptNode
## Script responsible for controling the ambient soundscape.

const SETTING_KEY = "Ambience"

var placeholder = "empty"
var soundscape = [load("res://sound_effects/yippee.wav"), load("res://sound_effects/tap.wav")]
var sound_settings
signal finished_loading()

## Custom streamplayer class, that loops audio by default.
class AmbientSound extends AudioStreamPlayer:
	var hug: int
	func _init(loop: bool = true) -> void:
		self.hug = 12
		self.autoplay = true
		if loop:
			self.connect("finished", _on_finished)

	func _on_finished() -> void:
		await get_tree().create_timer(1).timeout # Wait 1 second before looping again.
		self.play()


func _ready() -> void:
	# Once loading is finished then load the scoundscape.
	finished_loading.connect(load_soundscape)


func load_soundscape() -> void:
	if sound_settings:
		for sound_setting in sound_settings:
			add_sound_node(sound_setting)
		print(placeholder) # <- just checking save/loading


## Create a [param AmbientSound] with the passed audio file.
func add_sound_node(sound: AudioStream) -> void:
	var sound_node = AmbientSound.new()
	sound_node.stream = sound
	#sound_node.name = sound.resource_path
	add_child(sound_node)


func save() -> Dictionary:
	var settings_data = []
	var nodes = get_children()
	for node in nodes:
		settings_data.append(node.hug)
	
	return {"section": Globals.AUDIO_SECTION, SETTING_KEY: settings_data}


func load(data) -> void:
	if data.has(SETTING_KEY):
		self.placeholder = data[SETTING_KEY]
	finished_loading.emit()
	
func blah():
	var children = get_children()
	for child in children:
		print(child.hug)
