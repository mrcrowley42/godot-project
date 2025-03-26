extends Area2D

@onready var creature: Creature = %Creature


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_pressed() and creature.life_stage == Creature.LifeStage.EGG:
		creature.do_movement(Creature.Movement.EGG_WIGGLE)
