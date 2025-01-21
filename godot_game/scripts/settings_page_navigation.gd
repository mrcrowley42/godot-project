extends VBoxContainer

@export var page_label: Label
@export var left_btn: Button
@export var right_btn: Button
@export var pages_parent_node: Control

var all_pages = []
var current_page_num = 0

func _ready():
	all_pages = pages_parent_node.get_children()
	
	left_btn.connect('button_down', left)
	right_btn.connect('button_down', right)
	update_page_label()
	update_page_visibility()

func shift_screen(offset:int) -> void:
	current_page_num = Helpers.wrap_index(all_pages, current_page_num, offset)
	update_page_label()
	update_page_visibility()

func update_page_label():
	page_label.text = all_pages[current_page_num].name

func update_page_visibility():
	var i = 0
	for page in all_pages:
		page.visible = i == current_page_num
		i += 1

func left():
	shift_screen(-1)

func right():
	shift_screen(1)
