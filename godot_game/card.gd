extends Button

class_name Card

#var back = Gradient.new()
var back = load("res://images/pixel_egg.png")
var face =  load("res://images/pixel_baby.png")

func _init(value):
	text = value
	#texture_normal = back
	#ignore_texture_size = true
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	
