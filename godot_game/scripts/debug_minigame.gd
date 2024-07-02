extends Label


var og_text = self.text

func _process(_delta):
	var m_man = find_parent('DebugContent').minigame_man
	self.text = og_text % [m_man.currentMinigame]
