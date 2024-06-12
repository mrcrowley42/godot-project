extends HSlider

@export var bus_name: String 
var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	value = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)

func _on_value_changed(vol_value: float) -> void:
	if vol_value == 0:
		AudioServer.set_bus_mute(bus_index,true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(vol_value))

func save():
	return {"section": Globals.AUDIO_SECTION, self.name: self.value}

func load(data):
	self.value = data[self.name]
