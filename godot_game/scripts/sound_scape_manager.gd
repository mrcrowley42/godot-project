class_name AmbienceManager extends ScriptNode
## Script responsible for controling the ambient soundscape.

const KEY = "Ambience"
var placeholder = "empty"

func save() -> Dictionary:
	return {"section": Globals.AUDIO_SECTION, KEY: "placeholder"}


func load(data) -> void:
	if data.has(KEY):
		self.placeholder = data[KEY]

# TODO add audiostream2d nodes as needed and queue free them as well.
