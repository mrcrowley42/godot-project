extends ProgressBar
@onready var creature = %Creature

func _ready():
	creature.sp_changed.connect(update_sp_bar)
	update_sp_bar()

func update_sp_bar():
	self.value = creature.sp
