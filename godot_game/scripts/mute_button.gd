extends Button


@export var bus_name: String 
var bus_index: int
var muted: bool = false
@onready var VOLUME = preload("res://icons/volume-fill.svg")
@onready var VOLUME_MUTED = preload("res://icons/volume-mute-fill.svg")

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	update_mute_state()

func _on_button_down():
	muted = !muted
	update_mute_state()
	
	
func update_mute_state():
	if muted:
		self.icon = VOLUME_MUTED
	else:
		self.icon = VOLUME
	AudioServer.set_bus_mute(bus_index, muted)
	
func save():
	return {"section": Globals.AUDIO_SECTION, self.name: self.muted}

func load(data):
	# won't complain if setting isn't there.
	if data.has(self.name):
		if data[self.name] != null:
			self.muted = data[self.name]
			update_mute_state()

