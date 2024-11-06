class_name VolumeSlider extends HSlider

## Class for Volume Sliders

@export var bus_name: String
var bus_index: int

@onready var value_label: Label = get_child(0)

func update_label():
	value_label.text = str(value * 100)

func _ready() -> void:
	update_label()
	
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	self.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _on_value_changed(vol_value: float) -> void:
	update_label()
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(vol_value))

## stay in the middle
func _on_item_rect_changed() -> void:
	if value_label != null:
		value_label.size = size
		value_label.scale = scale


func save() -> Dictionary:
	return {"section": Globals.AUDIO_SECTION, self.name: self.value}

func load(data) -> void:
	if data.has(self.name):
		self.value = data[self.name]
