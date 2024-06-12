extends ProgressBar


func _ready():
	self.max_value = %Creature.max_mp

func _process(_delta):
	self.value = %Creature.mp

func save():
	return {"value": self.value}

func load(data):
	%Creature.mp = data["value"]
