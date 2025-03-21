extends Label

var og_text = self.text

func _process(_delta):
	var stats: StatusManager = get_node("..").stat_man
	var rate = stats.health_amount * (stats.hp_rate * stats.time_multiplier)
	self.text = og_text % [
			str(round(find_parent('DebugContent').creature.hp)),
			str(round(rate))
		]
