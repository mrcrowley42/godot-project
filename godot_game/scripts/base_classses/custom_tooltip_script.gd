@icon("res://icons/class-icons/chat-square-heart-fill.svg")
class_name CustomTooltipButton extends Button

var THEME_DICT = {
	THEME.PLAIN: load("res://themes/plain.tres"),
	THEME.GREY: load("res://themes/menu_btn.tres"),
	THEME.DARK_GREY: load("res://themes/menu_btn_dark.tres")
}

enum THEME {PLAIN, GREY, DARK_GREY}
enum DIRECTION {SMART_HORIZONTAL, SMART_VERTICAL, UP, DOWN, LEFT, RIGHT}

@export_multiline var tooltip_string: String
@export var style: THEME
@export var direction: DIRECTION
@export var tooltip_scale: float = 1
## margin between button and tooltip
@export var margin: int = 10
## allow the tooltip to overflow past the edge of the viewport
@export var allow_edge_overflow: bool = false

var tooltip_object: Label


func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	
	add_child(generate_tooltip_object())
	
	tooltip_object.modulate = Color(1, 1, 1, 0)
	tooltip_text = ""  # override lol


func generate_tooltip_object() -> CanvasLayer:
	tooltip_object = Label.new()
	tooltip_object.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tooltip_object.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tooltip_object.scale = Vector2(tooltip_scale, tooltip_scale)
	
	tooltip_object.theme = THEME_DICT[style]
	var cl = CanvasLayer.new()
	cl.layer = 10;
	cl.add_child(tooltip_object)
	return cl


## find pos of tooltip
func place_tooltip():
	tooltip_object.position = global_position
	
	var tt_size = tooltip_object.size * tooltip_object.scale
	var this_size = size * scale
	var vp_size = get_viewport_rect().size
	
	# smart positions
	var smart_dir = null;
	if direction == DIRECTION.SMART_HORIZONTAL:
		smart_dir = DIRECTION.RIGHT
		if global_position.x + (this_size.x * .5) > vp_size.x * .5:
			smart_dir = DIRECTION.LEFT
	
	if direction == DIRECTION.SMART_VERTICAL:
		smart_dir = DIRECTION.DOWN
		if global_position.y + (this_size.y * .5) > vp_size.y * .5:
			smart_dir = DIRECTION.UP
	
	# static positions
	if direction == DIRECTION.UP or smart_dir == DIRECTION.UP:
		tooltip_object.position.x += -(tt_size.x - this_size.x) * .5
		tooltip_object.position.y += -tt_size.y - margin
	
	if direction == DIRECTION.DOWN or smart_dir == DIRECTION.DOWN:
		tooltip_object.position.x += -(tt_size.x - this_size.x) * .5
		tooltip_object.position.y += this_size.y + margin
	
	if direction == DIRECTION.LEFT or smart_dir == DIRECTION.LEFT:
		tooltip_object.position.y += -(tt_size.y - this_size.y) * .5
		tooltip_object.position.x += -(tt_size.x + margin)
	
	if direction == DIRECTION.RIGHT or smart_dir == DIRECTION.RIGHT:
		tooltip_object.position.y += -(tt_size.y - this_size.y) * .5
		tooltip_object.position.x += this_size.x + margin


## update string & tooltip position
func update_tooltip():
	tooltip_object.text = tooltip_string  # refresh text
	place_tooltip()  # string is different size, re-place


func on_mouse_entered():
	if visible and tooltip_string.length() > 0:
		update_tooltip()
		Globals.tween(tooltip_object, "modulate", Color(1, 1, 1, 1), 0, .3)
		#Globals.tween(tooltip_object, "position", og_pos, 0, .3)


func on_mouse_exited():
	if visible:
		Globals.tween(tooltip_object, "modulate", Color(1, 1, 1, 0), 0, .3)
		#Globals.tween(tooltip_object, "position", og_pos + BTN_LABEL_OFFSET, 0, .3)
