extends Area2D


func get_all_positions():
	var p = []
	for shape: CollisionShape2D in get_children():
		p.append(shape.position)
	return p
