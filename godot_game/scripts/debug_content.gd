extends Control

@onready var creature: Creature = %Creature
@onready var ui = %UI_Theme_Manager
@onready var stat_man = %StatusManager
@onready var music_track = %MainMusic
@onready var screen_tint = %BG
@onready var minigame_man: MinigameManager = %MinigameManager
@onready var drag_area: Button  = %DragArea


func _on_h_slider_value_changed(value):
	stat_man.time_multiplier = value

func _on_button_button_down():
	creature.reset_stats()
	
func _ready():
	var anims = creature.find_child('Main').sprite_frames.get_animation_names()
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
	creature.find_child('Main').animation = $AnimSelect.get_item_text(index)

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
	drag_area.toggle_clippy_mode()

func _on_h_slider_2_value_changed(value):
	drag_area.clippy_opacity = value
	if drag_area.clippy:
		creature.find_child("Sprites").self_modulate = Color(1,1,1,drag_area.clippy_opacity)


func _on_check_box_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	
