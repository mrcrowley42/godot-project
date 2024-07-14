extends Button

@onready var window: Window = get_window()
@onready var viewport = get_viewport()
var clippy_offset = Vector2(-128,-226)
var window_offset = Transform2D(0, clippy_offset) 
var dragging: bool = false
var offset = Vector2(0, 0)
var start_size: Vector2
var start_transform: Transform2D
var default_stretch_mode: int

func _ready():
	visible = false
	start_size = window.size
	start_transform = viewport.canvas_transform
	default_stretch_mode = window.content_scale_mode
	

func _process(_delta):
	# Update window position relative to mouse position when clicking and dragging.
	if dragging:
		window.position = DisplayServer.mouse_get_position() - Vector2i(offset) - Vector2i(clippy_offset)

func _on_button_down():
	dragging = true
	offset = get_global_mouse_position()

func _on_button_up():
	dragging = false
	
func _input(event):
	if event is InputEventMouseButton and visible:
		if event.double_click:
			%DebugContent._on_clippy_btn_pressed()
