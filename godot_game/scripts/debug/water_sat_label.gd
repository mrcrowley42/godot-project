extends Label

var og_text = self.text

func _process(_delta):
	self.text = og_text % str(find_parent('DebugContent').creature.water_saturation)
