extends ProgressBar
@onready var creature = %Creature

func _ready():
	creature.hp_changed.connect(update_hp_bar)
	update_hp_bar()

func update_hp_bar():
	self.value = creature.hp
