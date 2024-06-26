extends Label

var og_text = self.text

func _process(_delta):
	var stats = get_node("..").stat_man
	var rate = -(stats.mp_amount * (stats.mp_rate * stats.time_multiplier))
	self.text = og_text % [
			str(round(get_node("..").creature.mp)), 
			str(rate)
		]
