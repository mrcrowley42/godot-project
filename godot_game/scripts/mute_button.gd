extends Button


@export var bus_name: String 
var bus_index: int
var muted: bool = false
@onready var VOLUME = preload("res://icons/volume-fill.svg")
@onready var VOLUME_MUTED = preload("res://icons/volume-mute-fill.svg")
func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)

	

func _on_button_down():
	muted = !muted
	if muted:
		self.icon = VOLUME_MUTED
	else:
		self.icon = VOLUME
	AudioServer.set_bus_mute(bus_index, muted)
