class_name AmbienceManager extends ScriptNode
## Script responsible for controling the ambient soundscape.

func save() -> Dictionary:
	return {"section": Globals.AUDIO_SECTION, self.name: "placeholder"}

#func load(data) -> void:
	#if data.has(self.name):
		#self.value = data[self.name]
