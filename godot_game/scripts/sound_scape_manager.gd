class_name AmbienceManager extends ScriptNode
## Script responsible for controling the ambient soundscape.

const SETTING_KEY = "Ambience"

var soundscape = []
var sound_list = build_sound_map()

signal finished_loading()

## Custom streamplayer class, that loops audio by default.
class AmbientSoundPlayer extends AudioStreamPlayer:
	var sound_name: String

	func _init(loop: bool = true) -> void:
		self.bus = &"Music" # Using Music bus for now.
		self.autoplay = true
		if loop:
			self.connect("finished", _on_finished)

	func _on_finished() -> void:
		await get_tree().create_timer(1).timeout # Wait 1 second before looping again.
		self.play()


func _ready() -> void:
	# Once loading is finished then load the scoundscape.
	finished_loading.connect(load_soundscape)


## Regenerate soundscape from saved settings.
func load_soundscape() -> void:
	if soundscape:
		for sound in soundscape:
			var audio = load(sound_list[sound[0]])
			var volume = sound[1]
			add_sound_node(audio, volume)


## Create a [param AmbientSound] with the passed audio file.
func add_sound_node(sound: AudioStream, volume: float = 0.5) -> void:
	var sound_node = AmbientSound.new()
	sound_node.stream = sound
	sound_node.volume_db = linear_to_db(volume)
	sound_node.sound_name = get_file_name(sound)
	add_child(sound_node)


func save() -> Dictionary:
	var settings_data = []
	var nodes = get_children()
	for node in nodes:
		settings_data.append([
			node.sound_name,
			db_to_linear(node.volume_db)])

	#soundscape = settings_data
	return {"section": Globals.AUDIO_SECTION, SETTING_KEY: settings_data}


func load(data) -> void:
	if data.has(SETTING_KEY):
		self.soundscape = data[SETTING_KEY]
	finished_loading.emit()


## [DEBUG] Print current soundscape.
func current_sounds():
	print(soundscape)


## Returns the file name of an audio file.
func get_file_name(sound: Resource) -> String:
	return sound.resource_path.get_file().get_basename()


## Returns a dictionary of file_names to resource_path for each ambient sound.
func build_sound_map() -> Dictionary:
	var sound_dict = Dictionary()
	for sound in load("res://resources/ambient_sounds/categories/category_fire.tres").sound_resources:
		sound_dict[get_file_name(sound)] = sound.file
	return sound_dict
