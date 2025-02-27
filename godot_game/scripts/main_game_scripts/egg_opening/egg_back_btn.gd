extends NinePatchRect

@onready var parent: EggOpening = find_parent("EggOpening")

## bring back egg selection
func _on_gui_input(event):
	if parent.can_interact and event.is_pressed():
		%SFX.pitch_scale = 1.  # reset
		%SFX.play_sound("click")
		if parent.selected_egg_inx == null:
			parent.back_to_main_menu.emit()
			parent.fade(self, false, .0, true)
		else:
			parent.set_can_interact(false)
			parent.fade(parent.bar_container, false)
			parent.tween_sprite_to_goal(parent.original_egg_positions[parent.selected_egg_inx], parent.BASE_EGG_SCALE, true)
			
			# reset texts, shader & rotation
			parent.selection_title.text = parent.select_title_text % [parent.STRING_SELECT_YOUR_EGG]
			parent.tween(parent.shader_area.material, "shader_parameter/color", Vector4(0, 0, 0, 1), 0., 1., Tween.EASE_IN_OUT)
			parent.placed_egg_sprites[parent.selected_egg_inx].rotation = 0
			
			# fade back in other eggs
			for i: int in parent.placed_egg_sprites.size():
				if i != parent.selected_egg_inx:
					var sprite_c: Control = parent.placed_egg_sprites[i]
					parent.tween(sprite_c, "modulate", Color(1, 1, 1, 1), 0., .4)  # fade in
					parent.tween(sprite_c, "position", parent.original_egg_positions[i], 0., .3)  # move up
