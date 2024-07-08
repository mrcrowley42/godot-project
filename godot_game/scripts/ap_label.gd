extends Label

var og_text = self.text

func _process(_delta):
	var stats = get_node("..").stat_man
	var rate = -(stats.ap_amount * (stats.ap_rate * stats.time_multiplier))
	self.text = og_text % [
			str(round(find_parent('DebugContent').creature.ap)),
			str(rate)
		]
