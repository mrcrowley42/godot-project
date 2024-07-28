extends ScriptNode

func generate_confetti():
	var confetti_l = find_child("ConfettiParticleL");
	var confetti_r = find_child("ConfettiParticleR");
	
	var new_l = confetti_l.duplicate()
	var new_r = confetti_r.duplicate()
	
	%Yip.play()
	new_l.emitting = true;
	new_r.emitting = true;
	new_l.connect("finished", remove.bind(new_l))
	new_r.connect("finished", remove.bind(new_r))
	add_child(new_l)
	add_child(new_r)

func remove(obj):
	obj.queue_free()

func _input(event):
	if (event is InputEventKey) and event.pressed:
		if event.keycode == KEY_Y:
			generate_confetti()
			
