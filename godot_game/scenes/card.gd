## Class that describes the cards (buttons) for memory.
class_name Card extends Button
var hidden_value

func _init(value):
	text = "?"
	hidden_value = value
	theme = load("res://themes/monospace_font.tres")
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
func _pressed():
	find_parent("GameLogic").choose_card(self)
	
func flip_card():
	if text == "?":
		text = hidden_value
	else:
		text = "?"
	
