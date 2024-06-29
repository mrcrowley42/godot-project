extends Label

var og_text = self.text

func _process(_delta):
	self.text = og_text % [
		find_parent('DebugContent').UI.texture.resource_path.get_slice('_',1).trim_suffix('.png').capitalize()
		]
