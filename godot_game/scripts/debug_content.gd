extends Control

@onready var creature: Creature = %Creature
@onready var UI = %UI_Overlay
@onready var stat_man = %StatusManager
@onready var music_track = %MainMusic
@onready var screen_tint = %BG
@onready var minigame_man = %MinigameManager
@onready var drag_area: Button  = %DragArea

var clippy: bool = false
func _on_h_slider_value_changed(value):
	stat_man.time_multiplier = value

func _on_button_button_down():
	creature.reset_stats()
	
func _ready():
	var anims = creature.find_child('AnimatedSprite2D').sprite_frames.get_animation_names()
	for anim in anims:
		$AnimSelect.add_item(anim)
	$AnimSelect.selected = 3
	$ColorPickerButton.color = creature.dying_colour
	stat_man.finished_loading.connect(update_holiday)
	
	
func update_holiday():
	if stat_man.holiday_mode:
		$HolidayBtn.set_pressed_no_signal(true)
		
func _process(_delta):
	var fps = Engine.get_frames_per_second()
	$Label3.text = str(fps)
	if fps < 49.0:
		$Label3.set("theme_override_colors/font_color", Color.LIGHT_CORAL)
	elif fps < 59.0:
		$Label3.set("theme_override_colors/font_color", Color.LIGHT_GOLDENROD)
	else:
		$Label3.set("theme_override_colors/font_color", Color.LIGHT_GREEN)
	
func _on_anim_select_item_selected(index):
	creature.find_child('AnimatedSprite2D').animation = $AnimSelect.get_item_text(index)

func _on_overlay_strength_value_changed(value):
	screen_tint.material.set("shader_parameter/tint_strength", value)

func _on_color_picker_button_popup_closed():
	creature.dying_colour = $ColorPickerButton.color

func _on_hat_btn_button_down():
	creature.find_child('Hat').visible = !creature.find_child('Hat').visible

func _on_glasses_btn_button_down():
	creature.find_child('Glasses').visible = !creature.find_child('Glasses').visible

func _on_button_3_toggled(toggled_on):
	stat_man.holiday_mode = toggled_on
	print(stat_man.holiday_mode)

func _on_clippy_btn_pressed():
	toggle_clippy_mode()
	
func toggle_clippy_mode():
	clippy = !clippy # flip bool.
	# Use clippy bool to drive window settings. 
	drag_area.visible = clippy
	drag_area.viewport.transparent_bg = clippy
	drag_area.window.borderless = clippy
	drag_area.window.transparent = clippy
	drag_area.window.always_on_top = clippy
	
	if clippy:
		# Shrink window size and shift canvas to keep focus on creature.
		drag_area.window.content_scale_mode = 0
		drag_area.window.position -= Vector2i(drag_area.clippy_offset)
		drag_area.window.size = drag_area.start_size * 0.5
		drag_area.window.canvas_transform = drag_area.window_offset
		#drag_area.window.move_to_center()
	else:
		# Revert changes
		drag_area.window.position += Vector2i(drag_area.clippy_offset)
		drag_area.window.content_scale_mode = drag_area.default_stretch_mode
		drag_area.window.size = drag_area.start_size
		drag_area.window.canvas_transform = drag_area.start_transform
		#var a: Window = drag_area.window
		
	# Hide UI and background while in clippy.
	%UI.visible = !clippy
	%BG.visible = !clippy
