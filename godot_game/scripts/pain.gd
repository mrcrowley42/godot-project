extends AudioStreamPlayer
@export var sounds: Array[AudioStream]

func play_random() -> void:
	## Play random sound from [param sounds] pool.
	var audio = sounds.pick_random()
	self.stream = audio
	self.play()
