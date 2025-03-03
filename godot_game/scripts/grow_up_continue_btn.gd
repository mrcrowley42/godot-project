extends NinePatchRect


@onready var parent: GrowUpToAdult = find_parent("GrowUp")

func _on_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and visible:
		Globals.has_creature_just_grown_up = true
		Globals.perform_closing_transition(
			parent.trans_img, 
			parent.mid_pos,
			Globals.change_to_scene.bind("res://scenes/GameScenes/main.tscn")
		)
