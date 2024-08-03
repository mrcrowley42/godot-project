extends ProgressBar
@onready var creature = %Creature

func _ready():
	creature.food_changed.connect(update_food_bar)
	update_food_bar()

func update_food_bar():
	self.value = creature.food
