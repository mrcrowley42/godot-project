extends Label

func _process(_delta):
	var hp = get_node("..").creature.health
	text = "Creature Health: " + str(hp)
