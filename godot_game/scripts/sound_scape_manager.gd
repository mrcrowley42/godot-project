class_name AmbienceManager extends ScriptNode
## Script responsible for controling the ambient soundscape.

const SETTING_KEY = "Ambience"
var placeholder = "empty"
signal finished_loading()

class AmbientSound extends AudioStreamPlayer2D:
	func _init() -> void:
		pass


func _ready() -> void:
	finished_loading.connect(load_soundscape)


func load_soundscape() -> void:
	add_sound_node()
	print(placeholder)


func add_sound_node() -> void:
	var sound_node = AmbientSound.new()
	add_child(sound_node)


func save() -> Dictionary:
	return {"section": Globals.AUDIO_SECTION, SETTING_KEY: "placeholder"}


func load(data) -> void:
	if data.has(SETTING_KEY):
		self.placeholder = data[SETTING_KEY]
	finished_loading.emit()
