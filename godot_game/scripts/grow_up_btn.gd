extends NinePatchRect

@onready var btn_label: NinePatchRect = find_child("GUBLabel")
var btn_label_og_pos: Vector2
const BTN_LABEL_OFFSET: Vector2 = Vector2(0, 10)

var og_pos: Vector2

func _ready() -> void:
	og_pos = position
	visible = false
	btn_label.modulate = Color(1, 1, 1, 0)
	btn_label_og_pos = btn_label.position
	btn_label.position = btn_label_og_pos + BTN_LABEL_OFFSET


func show_grow_up_btn():
	visible = true
	tween(self, "position", og_pos, 0, 1.)

func _on_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and %Creature.is_ready_to_grow_up:
		get_tree().root.propagate_notification(Globals.NOFITICATION_GROW_TO_ADULT_SCENE)

## generic tween function
func tween(obj, prop, val, delay=0., time=2., _ease=Tween.EASE_OUT):
	var t = get_tree().create_tween()
	t.tween_property(obj, prop, val, time)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(_ease)\
			.set_delay(delay)
	return t

func _on_mouse_entered() -> void:
	if visible:
		tween(btn_label, "modulate", Color(1, 1, 1, 1), 0, .3)
		tween(btn_label, "position", btn_label_og_pos, 0, .3)


func _on_mouse_exited() -> void:
	if visible:
		tween(btn_label, "modulate", Color(1, 1, 1, 0), 0, .3)
		tween(btn_label, "position", btn_label_og_pos + BTN_LABEL_OFFSET, 0, .3)
