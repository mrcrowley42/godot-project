extends ProgressBar
@onready var creature: Creature = %Creature

func _ready() -> void:
	creature.hp_changed.connect(update_hp_bar)
	update_hp_bar()

func update_hp_bar() -> void:
	self.value = creature.hp
