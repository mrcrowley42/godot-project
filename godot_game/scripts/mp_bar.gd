extends ProgressBar
@onready var creature = %Creature

func _ready():
	creature.mp_changed.connect(update_mp_bar)
	update_mp_bar()

func update_mp_bar():
	self.value = creature.mp

