extends ProgressBar

@onready var creature = %Creature
@export_enum("fun", "food", "water", "hp") var stat: String

func _ready():
	creature[stat+"_changed"].connect(update_bar)
	update_bar()


func update_bar():
	self.value = creature[stat]
