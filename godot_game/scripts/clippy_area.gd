extends Button

const OPACITY_SETTING = "ClippyOpacity"
const MUTE_SETTING = "MuteSFXInClippyMode"
const MUTE_AMBIENCE_SETTING = "MuteAmbInClippyMode"

## Clippy mode and window size functions are stored here.
@export var scale_factor: float = 2.0
@export var ambience_manager: AmbienceManager

@onready var window: Window = get_window()
@onready var viewport: Viewport = get_viewport()
@onready var creature: Creature = %Creature
@onready var start_scale := creature.scale
@onready var start_size := window.size
@onready var start_transform := viewport.canvas_transform
@onready var default_stretch_mode := window.content_scale_mode
@onready var clippy_offset := -self.position
@onready var ui = %UI
@onready var bg = %BGCanvasLayer
@onready var notif_layer = find_parent("Game").find_child("NotificationLayer")
@onready var sfx_bus = AudioServer.get_bus_index("SFX")

var dragging: bool = false
var offset = Vector2(0, 0)
var clippy: bool = false
var clippy_opacity := 0.5
var mute_sfx = false
var mute_ambience = false

signal clippy_closed

func _ready() -> void:
	visible = false
	clippy_closed.connect(reset_scale)


func reset_scale() -> void:
	creature.scale = start_scale


func _process(_delta) -> void:
	# Update window position relative to mouse position when clicking and dragging.
	if dragging:
		window.position = DisplayServer.mouse_get_position() - Vector2i(offset) - Vector2i(clippy_offset)


func _on_button_down() -> void:
	dragging = true
	offset = get_global_mouse_position()


func _on_button_up() -> void:
	dragging = false


func _input(event) -> void :
	if event is InputEventMouseButton and visible:
		if event.double_click:
			%DebugContent._on_clippy_btn_pressed()


func toggle_clippy_mode() -> void:
	# Don't enter clippy if a minigame is running.
	if %MinigameManager.current_minigame != null:
		return
	clippy = !clippy # flip bool.
	clippy_closed.emit()
	# Use clippy bool to drive window settings and element visibility.
	visible = clippy
	viewport.transparent_bg = clippy
	window.transparent = clippy
	window.always_on_top = clippy
	ui.visible = !clippy
	bg.visible = !clippy
	
	AudioServer.set_bus_mute(sfx_bus, clippy)

	# Hide notifications already on screen when going into clippy mode
	for child in notif_layer.get_child(0).get_children():
		if child is PanelContainer:
			child.visible = !clippy

	if clippy:
		# Shrink window size and shift canvas to keep focus on creature.
		if mute_ambience:
			ambience_manager.fade_out()
		
		window.content_scale_mode = 0 as Window.ContentScaleMode
		window.position -= Vector2i(clippy_offset)
		window.size = self.size
		window.canvas_transform = Transform2D(0, -self.position)
		creature.find_child("Sprites").self_modulate = Color(1,1,1,clippy_opacity)
		minimise()
	else:
		# Revert changes
		if ambience_manager.is_faded_out:
			ambience_manager.fade_in()
		
		window.position += Vector2i(clippy_offset) # + Vector2i(2,0) # Why it wants to move 2 pixels I don't know might be mac specific problem?
		window.content_scale_mode = default_stretch_mode as Window.ContentScaleMode
		window.size = start_size
		window.canvas_transform = start_transform
		creature.find_child("Sprites").self_modulate = Color(1,1,1,1)
		

	# THIS IS SO DUMB!!!
	# Linux has needs a delay to activate borderless, so this delay is needed
	# otherwise the window doesn't centre itself
	if get_tree():
		if OS.get_name().to_lower() == "linux":
			await get_tree().process_frame
			await get_tree().process_frame
		window.borderless = clippy
	if not clippy:
		normalise()
	#print(window.position) # TODO REMOVE THIS PRINT AFTER CHECKING THERE IS NO WINDOW DRIFT!


func minimise() -> void:
	if clippy:
		creature.scale = start_scale / scale_factor
	else:
		window.size = start_size / scale_factor


func normalise() -> void:
	if clippy:
		creature.scale = start_scale
	else:
		window.size = start_size


func maximise() -> void:
	if clippy:
		creature.scale = start_scale * scale_factor
	else:
		window.size = start_size * scale_factor


func _on_clippy_btn_button_down() -> void:
	toggle_clippy_mode()


func _on_sfx_clippy_box_toggled(toggled_on: bool) -> void:
	mute_sfx = toggled_on

func _on_amb_clippy_box_toggled(toggled_on: bool):
	mute_ambience = toggled_on


func save() -> Dictionary:
	return {"section": Globals.AUDIO_SECTION,
	OPACITY_SETTING: clippy_opacity,
	MUTE_SETTING: mute_sfx,
	MUTE_AMBIENCE_SETTING: mute_ambience
	}

func load(data) -> void:
	if data.has(OPACITY_SETTING):
		%OpacitySlider.value = data[OPACITY_SETTING]
	if data.has(MUTE_SETTING):
		%SfxClippyBox.button_pressed = data[MUTE_SETTING]
	if data.has(MUTE_AMBIENCE_SETTING):
		%AmbClippyBox.button_pressed = data[MUTE_AMBIENCE_SETTING]
