extends AudioStreamPlayer
@export var sounds:Array[AudioStream]

func play_random():
	var audio = sounds.pick_random()
	self.stream = audio
	self.play()
