extends AudioStreamPlayer

# Store available tracks in a list.
@export var music_selection: Array[AudioStreamMP3]

## Index of the current track in the [param music_selection]
var i:int = 0
func _ready():
	# Play the track at loaded index.
	self.stream = music_selection[self.i]
	self.play()
	
func move_track(offset=0):
	# Wrap index around 
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
	self.i = int(data[self.name])
	move_track()	

func _on_finished():
	stream=music_selection.pick_random()
	play()
