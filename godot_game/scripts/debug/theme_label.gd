extends Label

var og_text = self.text

func _process(_delta):
	self.text = og_text % [
		find_parent('DebugContent').ui.current_theme.theme_name]
