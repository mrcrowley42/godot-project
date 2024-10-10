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
	if not soundscape:
		return
	for sound in soundscape:
		if sound_list.has(sound[0]):
			var audio = load(sound_list[sound[0]])
			var volume = sound[1]
			add_sound_node(audio, volume)
		else:
			soundscape.pop_front()  # Remove corrupt filenames


## Create a [param AmbientSoundPlayer] with the passed audio file.
func add_sound_node(sound: AmbientSound, volume: float = 0.5) -> void:
	var sound_node = AmbientSoundPlayer.new()
	sound_node.stream = sound.file
	sound_node.volume_db = linear_to_db(volume)
	sound_node.sound_name = sound.sound_name.to_lower().replace(" ",  "")
	add_child(sound_node)


func save() -> Dictionary:
	var settings_data = []
	var nodes = get_children()
	for node in nodes:
		settings_data.append([
			node.sound_name,
			db_to_linear(node.volume_db)])

	soundscape = settings_data
	return {"section": Globals.AUDIO_SECTION, SETTING_KEY: settings_data}


func load(data) -> void:
	if data.has(SETTING_KEY):
		self.soundscape = data[SETTING_KEY]
	finished_loading.emit()


## [DEBUG] Print current soundscape.
func current_sounds():
	print(soundscape)


## Returns a dictionary of file_names to resource_path for each ambient sound.
func build_sound_map() -> Dictionary:
	var sound_dict = Dictionary()
	for category in load("res://resources/ambience_categories.tres").items:
		for sound in category.sound_resources:
			# Format sound key to avoid strict formating.
			var sound_key: String = sound.sound_name.to_lower().replace(" ",  "")
			sound_dict[sound_key] = sound
	print(sound_dict)
	return sound_dict
