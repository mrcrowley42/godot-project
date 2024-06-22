extends Label

var og_text = self.text

func _process(_delta):
	self.text = og_text % [
			str(get_node("..").UI.i),
		]
