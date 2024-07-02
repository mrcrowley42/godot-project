extends AudioStreamPlayer

@export var music_selection: Array[AudioStreamMP3]
var i:int = 0

func _ready():
	self.stream = music_selection[self.i]
	self.play()
	

func change_texture(addition=0):
	self.i = (self.i + addition) % music_selection.size()
	stream = music_selection[self.i]
	self.play()

func cycle_forward():
	change_texture(1)

func cycle_backwards():
	change_texture(-1)
	
func save():
	return {"section": Globals.AUDIO_SECTION, self.name: abs(self.i)}

func load(data):
	self.i = int(data[self.name])
	change_texture()	



func _on_finished():
	stream=music_selection.pick_random()
	play()
