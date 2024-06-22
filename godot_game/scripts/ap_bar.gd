extends ProgressBar
@onready var creature = %Creature

func _ready():
	creature.ap_changed.connect(update_ap_bar)
	update_ap_bar()

func update_ap_bar():
	self.value = creature.ap
