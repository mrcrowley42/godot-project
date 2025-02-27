extends NinePatchRect

@onready var parent: EggOpening = find_parent("EggOpening")

## go to main scene
func _on_gui_input(event):
	if parent.can_interact and parent.finished_hatching and event.is_pressed():
		%SFX.play_sound("click")
		parent.set_can_interact(false)
		parent.do_closing_trans.emit()
