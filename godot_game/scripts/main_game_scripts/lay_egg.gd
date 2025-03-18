class_name LayEggScene extends ScriptNode

@export var back_btn: NinePatchRect
@export var next_btn: NinePatchRect
@export var lay_egg_btn: NinePatchRect
@export var display_box: NinePatchRect
@export var dialog_box: RichTextLabel

@onready var bg: NinePatchRect = find_child("BG")
@onready var mid_pos: Vector2 = bg.position + (bg.size * bg.scale) * .5
@onready var mid_display_pos: Vector2 = display_box.global_position - (display_box.size * display_box.scale) * .5
@onready var trans_img: Sprite2D = find_child("Transition")

const DISABLED = Color(1, 1, 1, .4)
const DEFAULT = Color(1, 1, 1, 1)

var dialog_page = 0
var DIALIDG_TREE = []

var creature_name = ""
var back_disabled = true
var next_disabled = false
var lay_egg_disabled = true

func _ready() -> void:
	creature_name = Globals.general_dict["creature_name"]
	Globals.general_dict.erase("creature_name")
	
	DIALIDG_TREE = [
		"You're creature, %s, has grown so much!" % creature_name,
		"You've taken care of %s from the moment it hatched from its egg." % creature_name,
		"You've seen %s learn and grow, through happy times and times of hardship." % creature_name,
		"%s has tried food it loves... and food it doesn't really like." % creature_name,
		"%s has played many games with you and has learnt the value of friendship." % creature_name,
		"%s loves trying on different accessories, and chilling out to soft ambience." % creature_name,
		"But %s is an adult now." % creature_name,
		"And its able to use the valuable experience and knowledge its gained to continue on its own.",
		"%s will miss you, it won't ever forget this journey." % creature_name,
		"%s is ready to become independent, and continue its adventure into new and unexplored territory." % creature_name,
		"Are you ready for a new journey as well?"
	]
	
	Globals.perform_opening_transition(trans_img, mid_pos)
	update_dialog()

func update_dialog(dialog_addition: int = 0):
	dialog_page = max(0, min(len(DIALIDG_TREE) - 1, dialog_page + dialog_addition))
	dialog_box.text = "[center]%s" % DIALIDG_TREE[dialog_page]
	
	back_disabled = dialog_page == 0
	next_disabled = dialog_page == len(DIALIDG_TREE) - 1
	lay_egg_disabled = !next_disabled
	
	back_btn.modulate = DISABLED if back_disabled else DEFAULT
	next_btn.modulate = DISABLED if next_disabled else DEFAULT
	lay_egg_btn.modulate = DISABLED if lay_egg_disabled else DEFAULT
	
	if dialog_addition != 0:
		%SFX.play_sound("click")


func _on_back_btn_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and not back_disabled:
		update_dialog(-1)

func _on_next_btn_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and not next_disabled:
		update_dialog(1)

func _on_lay_btn_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and not lay_egg_disabled:
		pass
