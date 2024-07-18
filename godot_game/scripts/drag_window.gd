extends Button

@onready var window: Window = get_window()
@onready var viewport: Viewport = get_viewport()
@onready var creature: Creature = %Creature

@onready var start_scale := creature.scale
@onready var start_size := window.size
@onready var start_transform := viewport.canvas_transform
@onready var default_stretch_mode := window.content_scale_mode

const scale_factor = 2
var clippy_offset = Vector2(-128,-226)
#var clippy_offset = Vector2(-128,-206)
# TODO will need to adjust this to fit notifications and other creatures etc.
var window_offset = Transform2D(0, clippy_offset) 
var dragging: bool = false
var offset = Vector2(0, 0)
var clippy: bool = false

signal clippy_closed

func _ready():
	visible = false
	clippy_closed.connect(reset_scale)

func reset_scale():
	creature.scale = start_scale
	
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
	# Don't enter clippy if a minigame is running.
	if %MinigameManager.current_minigame != null:
		return 
	clippy = !clippy # flip bool.
	clippy_closed.emit()
	# Use clippy bool to drive window settings. 
	visible = clippy
	viewport.transparent_bg = clippy
	#window.transparent = clippy
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
	# THIS IS SO DUMB!
	# Linux has needs a delay to activate borderless otherwise the doesn't centre itself
	# so this is needed.... also windows has a slight shift due to borderless
	if get_tree():
		await get_tree().process_frame
		await get_tree().process_frame
		window.borderless = clippy
	
func minimise():
	if clippy:
		creature.scale = start_scale / scale_factor
	else:
		window.size = start_size / scale_factor

func normalise():
	if clippy:
		creature.scale = start_scale
	else:
		window.size = start_size

func maximise():
	if clippy:
		creature.scale = start_scale * scale_factor
	else:
		window.size = start_size * scale_factor
