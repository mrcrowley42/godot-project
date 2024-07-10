extends Label

var og_text = self.text

func _process(_delta):
	var m_man = find_parent('DebugContent').minigame_man
	# ugly but works
	var game_name = str(m_man.current_minigame).get_slice("scenes/", 1).trim_suffix(".tscn").replace("_", " ").capitalize()
	self.text = og_text % [game_name]
