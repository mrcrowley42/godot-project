extends NinePatchRect

var og_pos: Vector2

func _ready() -> void:
	og_pos = position
	visible = false

func show_grow_up_btn():
	visible = true
	Globals.tween(self, "position", og_pos, 0, 1.)

func _on_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and %Creature.is_ready_to_grow_up:
		get_tree().root.propagate_notification(Globals.NOFITICATION_GROW_TO_ADULT_SCENE)
