extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#var tween = get_tree().create_tween()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.value = %Creature.mp


func save():
	return {"value": self.value}

func load(data):
	%Creature.mp = data["value"]
