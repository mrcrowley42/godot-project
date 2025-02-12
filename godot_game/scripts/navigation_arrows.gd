class_name NavigationArrows extends Node2D
@export var target_menu: Node
@export var left_arrow: Node
@export var right_arrow: Node
const xoffset: int = 400

@onready var init_pos = target_menu.position
@onready var screen_count := len(target_menu.get_children())
@onready var menu_positions := range(screen_count).map(func(n): return init_pos.x - (n * xoffset))
## current page
@onready var index = 0

## 1 parameter, index is passed
signal page_changed

## in case more screens are added after onready
func calc_screen_count():
	screen_count = len(target_menu.get_children())
	menu_positions = range(screen_count).map(func(n): return init_pos.x - (n * xoffset))

func shift_screen(offset:int) -> void:
	index = Helpers.wrap_index(menu_positions, index, offset)
	Globals.tween(target_menu, "position", Vector2(menu_positions[index], init_pos.y), 0., .167)
	page_changed.emit(index)


func _on_left_arrow_button_down() -> void:
	shift_screen(-1)
	if index == 0:
		left_arrow.hide()
	right_arrow.show()


func _on_right_arrow_button_down() -> void:
	shift_screen(1)
	if index == screen_count -1:
		right_arrow.hide()
	left_arrow.show()

func _input(event: InputEvent) -> void:
	if left_arrow.visible and event.is_action_pressed("arrow_left"):
		_on_left_arrow_button_down()
	elif right_arrow.visible and event.is_action_pressed("arrow_right"):
		_on_right_arrow_button_down()

func _on_visibility_changed():
	index = 0
	left_arrow.hide()
	target_menu.position.x = 0
	
	if screen_count < 2:
		right_arrow.hide()
	else:
		right_arrow.show()
