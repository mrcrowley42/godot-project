class_name GrowUpToAdult extends ScriptNode


@onready var bg: NinePatchRect = find_child("BG")
@onready var trans_img: Sprite2D = find_child("Transition")
@onready var continue_btn: NinePatchRect = find_child("ContinueBtn")


func _ready() -> void:
	Globals.perform_opening_transition(trans_img, bg.position + (bg.size * bg.scale) * .5)

func finish_grow_up():
	%FastTimer.stop()
	%Confetti.fire()
	
	continue_btn.visible = true
	continue_btn.modulate = Color(1, 1, 1, 0)
	var t = get_tree().create_tween()
	t.tween_property(continue_btn, "modulate", Color(1, 1, 1, 1), .3)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)
	
	%EggDesc.text = "[center][font_size=15]Your creature is now an adult! Continue taking care of it to [insert something here]"
