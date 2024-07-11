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

@onready var og_text = $Label3.text

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
	$Label3.text = og_text % [str(Engine.get_frames_per_second())]
	if clippy:
		set_passthrough()
	#$Label3.set("theme_override_colors/font_color", Color.CORAL)
	
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
	clippy = !clippy
	var window = creature.get_window()
	drag_area.visible = clippy
	creature.get_viewport().transparent_bg = clippy
	#window.borderless = clippy
	window.transparent = clippy
	window.always_on_top = clippy
	

	
	
	%UI.visible = !clippy
	%BG.visible = !clippy
	
func set_passthrough():
	pass
	#DisplayServer.window_set_mouse_passthrough()
	#var area = drag_area.find_child("Polygon2D").polygon
	#get_window().mouse_passthrough_polygon = area
	#DisplayServer.window_set_mouse_passthrough(area)
