class_name AmbienceManager extends ScriptNode
## Script responsible for controling the ambient soundscape.

const SETTING_KEY = "Ambience"
@onready var ambience_bus_index = AudioServer.get_bus_index("Ambience")
var soundscape = []
var sound_list = build_sound_map()
var has_loaded = false

## Custom streamplayer class, that loops audio by default.
class AmbientSoundPlayer extends AudioStreamPlayer:
	var sound_category: AmbientSoundCategory
	var sound_name: String

	func _init(loop: bool = true) -> void:
		self.bus = &"Ambience" # Using Music bus for now.
		self.autoplay = true
		if loop:
			self.connect("finished", _on_finished)

	func _on_finished() -> void:
		await get_tree().create_timer(1).timeout # Wait 1 second before looping again.
		self.play()


## Regenerate soundscape from saved settings.
func load_soundscape() -> void:
	has_loaded = true
	if not soundscape:
		return
	
	# limit sounds count & remove invalid or corrupt sounds
	soundscape.resize(Globals.MAX_AMBIENT_SOUNDS)
	soundscape = soundscape.filter(func(x): return x != null && sound_list.has(to_sound_list_key(x[0])))
	
	# add sounds
	for sound in soundscape:
		var file = sound_list[to_sound_list_key(sound[0])]
		var volume = sound[1]
		var category = load(ResourceUID.get_id_path(int(sound[2])))
		add_sound_node(category, file, volume)

## Create a [param AmbientSoundPlayer] with the passed audio file.
func add_sound_node(category: AmbientSoundCategory, sound: AmbientSound, volume: float = 0.5) -> void:
	var sound_node = AmbientSoundPlayer.new()
	sound_node.stream = sound.file
	sound_node.volume_db = linear_to_db(volume)
	sound_node.sound_category = category
	sound_node.sound_name = sound.sound_name
	add_child(sound_node)


func save() -> Dictionary:
	var settings_data = []
	var sound_nodes = get_children()
	for s_node: AmbientSoundPlayer in sound_nodes:
		settings_data.append([
				s_node.sound_name,
				db_to_linear(s_node.volume_db),
				str(ResourceLoader.get_resource_uid(s_node.sound_category.resource_path))
			]
		)
	
	soundscape = settings_data
	return {"section": Globals.AUDIO_SECTION, SETTING_KEY: settings_data}


func load(data) -> void:
	if data.has(SETTING_KEY):
		self.soundscape = data[SETTING_KEY]
	load_soundscape()

func _notification(noti):
	if noti == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		load_soundscape()

func current_sounds():
	return get_children()

func get_sound_count():
	return len(current_sounds())

## Returns a dictionary of file_names to resource_path for each ambient sound.
func build_sound_map() -> Dictionary:
	var sound_dict = Dictionary()
	for category in load("res://resources/ambience_categories.tres").items:
		for sound in category.sound_resources:
			# Format sound key to avoid strict formating.
			var sound_key: String = to_sound_list_key(sound.sound_name)
			sound_dict[sound_key] = sound
	return sound_dict


func to_sound_list_key(key):
	return key.replace(" ", "_")


func fade_out():
	var t = create_tween()
	t.tween_method(update_bus_vol, 1.0, 0.0, 1.5)
	t.play()


func fade_in():
	var t = create_tween()
	t.tween_method(update_bus_vol, 0.0, 1.0, 1.5)
	t.play()


func update_bus_vol(value: float) -> void:
	AudioServer.set_bus_volume_db(ambience_bus_index, linear_to_db(value))
