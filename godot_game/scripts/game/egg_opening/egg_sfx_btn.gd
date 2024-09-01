extends NinePatchRect

@onready var parent: EggOpening = find_parent("EggOpening")

@onready var img = preload("res://icons/volume-fill.svg")
@onready var mute_img = preload("res://icons/volume-mute-fill.svg")

@onready var de_selected = preload("res://UI stuff/Green Palette/ui_green_box.png")
@onready var selected = preload("res://UI stuff/Green Palette/ui_green_box_inverted.png")

var muted: bool = false

## toggle sound
func _on_gui_input(event):
	if event.is_pressed():
		muted = !muted
		get_child(0).texture = mute_img if muted else img
		texture = selected if muted else de_selected
		
		%SFX.volume_db = -100. if muted else 0.
		%SFX.play_sound("click")
