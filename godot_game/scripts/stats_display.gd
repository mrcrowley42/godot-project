extends PanelContainer

@onready var creature: Creature = %Creature

@export var creature_stats: MarginContainer
@export var egg_stats: MarginContainer

func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_CREATURE_IS_LOADED:
		if creature.life_stage == Creature.LifeStage.EGG:
			creature_stats.hide()
			egg_stats.show()
		else:
			creature_stats.show()
			egg_stats.hide()
