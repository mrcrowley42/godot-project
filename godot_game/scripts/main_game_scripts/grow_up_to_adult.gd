class_name GrowUpToAdult extends ScriptNode


@onready var bg: NinePatchRect = find_child("BG")
@onready var mid_pos: Vector2 = bg.position + (bg.size * bg.scale) * .5
@onready var trans_img: Sprite2D = find_child("Transition")
@onready var continue_btn: NinePatchRect = find_child("ContinueBtn")


func _ready() -> void:
	Globals.perform_opening_transition(trans_img, mid_pos)

func finish_grow_up():
	%FastTimer.stop()
	Globals.fire_confetti(%ConfettiLayer, Vector2(270, 440))
	
	continue_btn.visible = true
	continue_btn.modulate = Color(1, 1, 1, 0)
	var t = get_tree().create_tween()
	t.tween_property(continue_btn, "modulate", Color(1, 1, 1, 1), 1)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(.5)
	
	%EggDesc.text = "[center][font_size=15]Your creature is now an adult! Continue taking care of it to [insert something here]"
