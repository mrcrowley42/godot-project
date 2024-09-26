extends NinePatchRect

@onready var parent: EggOpening = find_parent("EggOpening")

## go to main scene
func _on_gui_input(event):
	if parent.can_interact and parent.finished_hatching and event.is_pressed():
		%SFX.play_sound("click")
		parent.set_can_interact(false)
		parent.tween(%Music, "volume_db", -100, .0, .5, Tween.EASE_IN)  # ease out music
		
		Globals.perform_closing_transition(
			parent.trans_img, 
			parent.bg.position + (parent.bg.size * parent.bg.scale) * .5,
			parent.load_main_scene
		)
