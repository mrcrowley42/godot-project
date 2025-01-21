extends AudioStreamPlayer

var correct = preload("res://sound_effects/correct.wav")
var confirm = preload("res://sound_effects/confirm.wav")
var pop = preload("res://sound_effects/tap.wav")
var wrong = preload("res://sound_effects/wrong.wav")
var draw = preload("res://sound_effects/confirm.wav")
var click = preload("res://sound_effects/button_click_fast.mp3")
var yippe = preload("res://sound_effects/yippee.wav")

# tetris (8 & 16 bit sounds)
var t_place = preload("res://sound_effects/totris_place.wav")
var t_place_inst = preload("res://sound_effects/totris_place_inst.wav")
var t_biglinebreak = preload("res://sound_effects/totris_biglinebreak.wav")
var t_linebreak = preload("res://sound_effects/totris_linebreak.wav")
var t_no = preload("res://sound_effects/totris_no.wav")

# egg
var egg_crack_1 = preload("res://sound_effects/egg-crack-1.wav")
var egg_crack_2 = preload("res://sound_effects/egg-crack-2.wav")
var egg_crack_3 = preload("res://sound_effects/egg-crack-3.wav")

var card_flip_1 = preload("res://sound_effects/card_flip_1.mp3")

var lookup = {
	"draw": draw, "correct": correct, "confirm": confirm, "pop": pop, "wrong": wrong, "click": click, "yippe": yippe,
	"t_place": t_place, "t_place_inst": t_place_inst, "t_biglinebreak": t_biglinebreak, "t_linebreak": t_linebreak, "t_no": t_no,
	"egg_crack_1": egg_crack_1, "egg_crack_2": egg_crack_2, "egg_crack_3": egg_crack_3,
	"card_flip": card_flip_1,
}

func play_sound(sound_name):
	if !lookup.has(sound_name):
		printerr("The sound '" + sound_name + "' does not exist in the SFX lookup!")
		return
	stream = lookup[sound_name]
	play()
