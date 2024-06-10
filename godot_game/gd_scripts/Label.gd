extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = "Creature Health: " + str(%Creature.health)
