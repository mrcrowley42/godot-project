extends ProgressBar


func _ready():
	self.max_value = %Creature.max_health

func _process(_delta):
	self.value = %Creature.sp
