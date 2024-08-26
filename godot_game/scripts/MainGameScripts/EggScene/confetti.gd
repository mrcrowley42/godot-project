extends ScriptNode

func remove(obj: Object) -> void:
	obj.queue_free()

func confet() -> void:
	var confetti_l: CPUParticles2D = find_child("ConfetL");
	var confetti_r: CPUParticles2D = find_child("ConfetR");

	var new_l: CPUParticles2D = confetti_l.duplicate()
	var new_r: CPUParticles2D = confetti_r.duplicate()

	new_l.emitting = true;
	new_r.emitting = true;
	new_l.connect("finished", remove.bind(new_l))
	new_r.connect("finished", remove.bind(new_r))
	add_child(new_l)
	add_child(new_r)
