extends NinePatchRect

var pressed = false

func _on_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and not pressed:
		pressed = true
		var t = get_tree().create_tween()
		t.tween_property(self, "modulate", Color(1, 1, 1, 0), .3)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(Tween.EASE_OUT)
		
		%EggDesc.text = "[center]..."
		owner.start_grow_up()
