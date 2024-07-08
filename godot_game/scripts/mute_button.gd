class_name  MuteButton extends Button
## Class for Buttons that toggles whether a audio bus is muted or not.

var bus_index: int
var muted: bool = false
@export var bus_name: String
@onready var audio_enabled: Texture2D = preload ("res://icons/volume-fill.svg")
@onready var audio_muted: Texture2D = preload ("res://icons/volume-mute-fill.svg")

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	update_mute_state()

func _on_button_down() -> void:
	muted = !muted
	update_mute_state()
	
func update_mute_state() -> void:
	if muted:
		self.icon = audio_muted
	else:
		self.icon = audio_enabled
	AudioServer.set_bus_mute(bus_index, muted)
	
func save() -> Dictionary:
	return {"section": Globals.AUDIO_SECTION, self.name: self.muted}

func load(data) -> void:
	# won't complain if setting isn't there.
	if data.has(self.name):
		if data[self.name] != null:
			self.muted = data[self.name]
			update_mute_state()
