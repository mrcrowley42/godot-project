extends Button

@onready var window: Window = get_window()
var dragging: bool = false
var offset = Vector2(0, 0)

func _ready():
	visible = false

func _process(_delta):
	if dragging:
		window.position = DisplayServer.mouse_get_position()  - Vector2i(offset)

func _on_button_down():
	dragging = true
	offset = get_global_mouse_position()

func _on_button_up():
	dragging = false
