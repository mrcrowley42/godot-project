extends Label

var og_text = self.text

func _process(_delta):
	self.text = og_text % [
			str(get_node("..").creature.health), 
			str(get_node("..").stat_man.hp_rate)
		]