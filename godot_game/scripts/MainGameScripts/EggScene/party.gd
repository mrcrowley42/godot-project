extends Node2D



func remove(obj):
	obj.queue_free()

func confet():
	var confetti_l = find_child("ConfetL");
	var confetti_r = find_child("ConfetR");

	var new_l = confetti_l.duplicate()
	var new_r = confetti_r.duplicate()

	new_l.emitting = true;
	new_r.emitting = true;
	new_l.connect("finished", remove.bind(new_l))
	new_r.connect("finished", remove.bind(new_r))
	add_child(new_l)
	add_child(new_r)
