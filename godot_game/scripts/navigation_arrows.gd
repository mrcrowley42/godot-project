extends Node2D
@export var target_menu: Node
@export var left_arrow: Node
@export var right_arrow: Node
const xoffset: int = 400

@onready var init_pos = target_menu.position
@onready var screen_count := len(target_menu.get_children())
@onready var menu_positions := range(screen_count).map(func(n): return init_pos.x - (n * xoffset))
@onready var index = 0

func shift_screen(offset:int) -> void:
	index = Helpers.wrap_index(menu_positions, index, offset)
	var tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	tween.tween_property( target_menu, "position", Vector2(menu_positions[index], init_pos.y), .167)


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


func _on_visibility_changed():
	index = 0
	left_arrow.hide()
	right_arrow.show()
