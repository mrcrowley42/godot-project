extends AudioStreamPlayer

var correct = preload("res://sound_effects/correct.wav")
var wrong = preload("res://sound_effects/wrong.wav")
var draw = preload("res://sound_effects/confirm.wav")

# tetris (8 & 16 bit sounds, in desperate need of mixing)
var t_place = preload("res://sound_effects/totris_place.wav")
var t_place_inst = preload("res://sound_effects/totris_place_inst.wav")
var t_biglinebreak = preload("res://sound_effects/totris_biglinebreak.wav")
var t_linebreak = preload("res://sound_effects/totris_linebreak.wav")
var t_no = preload("res://sound_effects/totris_no.wav")

var lookup= {
	"draw": draw, "correct": correct, "wrong": wrong,
	"t_place": t_place, "t_place_inst": t_place_inst, "t_biglinebreak": t_biglinebreak, "t_linebreak": t_linebreak, "t_no": t_no
	}

func play_sound(sound_name):
	stream = lookup[sound_name]
	play()
