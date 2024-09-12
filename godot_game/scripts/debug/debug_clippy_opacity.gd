extends Label

func _process(_delta):
	text = '%.2f' % find_parent('DebugContent').clippy_area.clippy_opacity
