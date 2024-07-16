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
var clippy: bool = false

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


func toggle_clippy_mode():
	if %MinigameManager.current_minigame == null:
		clippy = !clippy # flip bool.
		# Use clippy bool to drive window settings. 
		visible = clippy
		viewport.transparent_bg = clippy
		window.borderless = clippy
		window.transparent = clippy
		window.always_on_top = clippy
		
		if clippy:
			# Shrink window size and shift canvas to keep focus on creature.
			window.content_scale_mode = 0 as Window.ContentScaleMode
			window.position -= Vector2i(clippy_offset)
			window.size = start_size * 0.5
			window.canvas_transform = window_offset
			
		else:
			# Revert changes
			window.position += Vector2i(clippy_offset)
			window.content_scale_mode = default_stretch_mode as Window.ContentScaleMode
			window.size = start_size
			window.canvas_transform = start_transform
			
		# Hide UI and background while in clippy.
		%UI.visible = !clippy
		%BG.visible = !clippy
		
