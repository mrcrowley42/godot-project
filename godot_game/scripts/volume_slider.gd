class_name VolumeSlider extends HSlider

## Class for Volume Sliders

@export var bus_name: String
var bus_index: int

func _ready() -> void:
	tooltip_text = str(value)
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	self.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _on_value_changed(vol_value: float) -> void:
	tooltip_text = str(value)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(vol_value))

func save() -> Dictionary:
	return {"section": Globals.AUDIO_SECTION, self.name: self.value}

func load(data) -> void:
	if data.has(self.name):
		self.value = data[self.name]
