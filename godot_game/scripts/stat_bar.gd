extends ProgressBar

@onready var creature: Creature = %Creature
@export_enum("fun", "food", "water", "hp") var stat: String

func _ready():
	creature[stat+"_changed"].connect(update_bar)
	update_bar()


func update_bar():
	var max_stat_name = 'max_' + stat
	self.max_value = creature[max_stat_name]
	self.value = creature[stat]
