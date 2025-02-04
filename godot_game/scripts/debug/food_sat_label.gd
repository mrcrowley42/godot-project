extends Label

var og_text = self.text

func _process(_delta):
	var stats = get_node("..").stat_man
	self.text = og_text % str(find_parent('DebugContent').creature.food_saturation)
