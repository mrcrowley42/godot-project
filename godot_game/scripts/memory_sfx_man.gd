extends AudioStreamPlayer

var correct = preload("res://sound_effects/correct.wav")
var wrong = preload("res://sound_effects/wrong.wav")
var draw = preload("res://sound_effects/confirm.wav")
var lookup= {"draw": draw, "correct": correct, "wrong": wrong}

func play_sound(sound_name):
	stream = lookup[sound_name]
	play()
