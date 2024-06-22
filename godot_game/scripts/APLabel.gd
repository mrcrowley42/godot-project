extends Label

var og_text = self.text

func _process(_delta):
	var stats = get_node("..").stat_man
	var rate = -(stats.ap_amount * stats.ap_rate)
	self.text = og_text % [
			str(get_node("..").creature.ap), 
			str(rate)
		]
