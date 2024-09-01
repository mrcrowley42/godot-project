extends NinePatchRect

@onready var parent: EggOpening = find_parent("EggOpening")

## go to main scene
func _on_gui_input(event):
	if parent.can_interact and parent.finished_hatching and event.is_pressed():
		%SFX.play_sound("click")
		parent.tween(%Music, "volume_db", -100, .0, 1., Tween.EASE_IN)  # ease out music
		parent.trans_img.rotation = PI
		parent.trans_img.position.y = -1000
		parent.tween(parent.trans_img, 
			"position", 
			parent.bg.position + (parent.bg.size * parent.bg.scale) * .5, 
			0., 
			1.
		).connect("finished", parent.load_main_scene)
