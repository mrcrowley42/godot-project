extends CheckBox


func save() -> Dictionary:
	return {"section": Globals.DEFAULT_SECTION, "skip_intro": self.button_pressed}

func load(data) -> void:
	if data.has("skip_intro"):
		button_pressed = data["skip_intro"]
