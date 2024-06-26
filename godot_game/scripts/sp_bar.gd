extends ProgressBar
@onready var creature = %Creature

func _ready():
	creature.sp_changed.connect(update_sp_bar)
	update_sp_bar()

func update_sp_bar():
	self.value = creature.sp

func save():
	return {"value": self.value}

func load(data):
	creature.sp = data["value"]
