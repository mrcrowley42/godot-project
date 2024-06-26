extends Label

var og_text = self.text

func _process(_delta):
	var stats = get_node("..").stat_man
	var rate = -(stats.hp_amount * (stats.hp_rate * stats.time_multiplier))
	self.text = og_text % [
			str(round(get_node("..").creature.health)), 
			str(rate)
		]
