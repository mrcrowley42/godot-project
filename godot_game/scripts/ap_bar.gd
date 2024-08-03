extends ProgressBar

@onready var creature = %Creature

func _ready():
	creature.fun_changed.connect(update_fun_bar)
	update_fun_bar()

func update_fun_bar():
	self.value = creature.fun
