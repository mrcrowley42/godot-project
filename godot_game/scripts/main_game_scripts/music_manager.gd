extends AudioStreamPlayer

# Store available tracks in a list.
@export var music_selection: Array[AudioStreamMP3]

## Index of the current track in the [param music_selection]
var i: int = 0

func _ready():
	stream = music_selection[self.i]
	play()


func move_track(offset=0) -> void:
	self.i = Helpers.wrap_index(music_selection, i, offset)
	stream = music_selection[self.i]
	self.play()


func cycle_forward():
	move_track(1)


func cycle_backwards():
	move_track(-1)


func save():
	return {"section": Globals.AUDIO_SECTION, self.name: abs(self.i)}


func load(data):
	if data.has(self.name):
		self.i = int(data[self.name])
	move_track()


func _on_finished() -> void:
	stream=music_selection.pick_random()
	play()
