extends Label

var og_text = self.text

func _process(_delta):
	var stats = get_node("..").stat_man
	var rate = -(stats.water_amount * (stats.water_rate * stats.time_multiplier))
	self.text = og_text % [
			str(round(find_parent('DebugContent').creature.water)),
			str(rate)
		]
