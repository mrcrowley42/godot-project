extends Button

@onready var window: Window = get_window()
var dragging: bool = false
var offset = Vector2(0, 0)
@onready var normal_cursor = mouse_default_cursor_shape

func _ready():
	visible = false

func _process(_delta):
	# Update window position relative to mouse position when clicking and dragging.
	if dragging:
		window.position = DisplayServer.mouse_get_position() - Vector2i(offset)

func _on_button_down():
	dragging = true
	offset = get_global_mouse_position()

func _on_button_up():
	dragging = false

func _on_mouse_entered():
	mouse_default_cursor_shape = Control.CURSOR_MOVE

func _on_mouse_exited():
	mouse_default_cursor_shape = normal_cursor
	
func _input(event):
	if event is InputEventMouseButton:
		if event.double_click:
			%DebugContent._on_clippy_btn_pressed()
