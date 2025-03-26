extends ProgressBar

@onready var creature: Creature = %Creature
@onready var label: Label = get_child(0)

var max_v = 0

func _ready() -> void:
	label.hide()

func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_CREATURE_IS_LOADED:
		if creature.life_stage == Creature.LifeStage.EGG:
			max_v = int(DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_INITIAL_EGG_TIME))
			creature.egg_time_remaining_changed.connect(update_bar)
			update_bar()

func update_bar():
	max_value = max_v
	value = max_v - creature.egg_time_remaining
	var perc = (float(value) / float(max_value)) * 100.
	perc = floor(perc * 100) / 100
	label.text = str(perc) + "%"


func _on_mouse_entered() -> void:
	label.show()

func _on_mouse_exited() -> void:
	label.hide()
