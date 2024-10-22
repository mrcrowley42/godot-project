@icon("res://icons/class-icons/chat-square-heart-fill.svg")
class_name CustomTooltipButton extends Button

var LABEL_THEME = load("res://themes/monospace_font.tres")
const TOOLTIP_MARGIN: int = 10;

## todo: change this based on current selected theme colour
var THEME_COLOUR_BEVEL_IMG = load("res://UI stuff/Green Palette/ui_green_box.png")
var THEME_DICT = {
	THEME.GREY: load("res://themes/menu_btn.tres"),
	THEME.DARK_GREY: load("res://themes/menu_btn_dark.tres")
}

enum THEME {GREY, DARK_GREY, COLOUR_BEVEL}
enum DIRECTION {AUTO_HORIZONTAL, AUTO_VERTICAL, UP, DOWN, LEFT, RIGHT}

@export var tooltip_string: String
@export var style: THEME
@export var direction: DIRECTION
@export var tooltip_scale: float = 1

var tooltip_object: Control;


func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	
	tooltip_object = Control.new()
	var label: Label = Label.new()
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.theme = LABEL_THEME
	label.text = tooltip_string
	label.scale = Vector2(tooltip_scale, tooltip_scale)
	
	tooltip_object.add_child(label)
	add_child(tooltip_object)
	tooltip_object.modulate = Color(1, 1, 1, 0)
	
	tooltip_text = ""  # override lol


func on_mouse_entered():
	if visible:
		tooltip_object.get_child(0).text = tooltip_string  # refresh text
		Globals.tween(tooltip_object, "modulate", Color(1, 1, 1, 1), 0, .3)
		#Globals.tween(tooltip_object, "position", og_pos, 0, .3)


func on_mouse_exited():
	if visible:
		Globals.tween(tooltip_object, "modulate", Color(1, 1, 1, 0), 0, .3)
		#Globals.tween(tooltip_object, "position", og_pos + BTN_LABEL_OFFSET, 0, .3)
