class_name GrowUpToAdult extends ScriptNode


@onready var bg: NinePatchRect = find_child("BG")
@onready var trans_img: Sprite2D = find_child("Transition")


func _ready() -> void:
	Globals.perform_opening_transition(trans_img, bg.position + (bg.size * bg.scale) * .5)
