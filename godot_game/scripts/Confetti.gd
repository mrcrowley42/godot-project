extends Node2D


func _input(event):	
	if (event is InputEventKey) and event.pressed:
		if event.keycode == KEY_Y:
			var confetti_l = get_child(0);
			var confetti_r = get_child(1);
			
			if !confetti_l.emitting and !confetti_r.emitting:
				confetti_l.restart();
				confetti_r.restart();
				confetti_l.emitting = true;
				confetti_r.emitting = true;
