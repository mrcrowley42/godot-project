extends Control

@onready var creature: Creature = %Creature
@onready var UI = %UI_Overlay
@onready var stat_man = %StatusManager
@onready var music_track = %MainMusic
@onready var screen_tint = %BG
@onready var minigame_man = %MinigameManager


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

func _process(_delta):
	$Label3.text = og_text % [str(Engine.get_frames_per_second())]
	#$Label3.set("theme_override_colors/font_color", Color.CORAL)
	
func _on_anim_select_item_selected(index):
	creature.find_child('AnimatedSprite2D').animation =$AnimSelect.get_item_text(index)


func _on_overlay_strength_value_changed(value):
	screen_tint.material.set("shader_parameter/tint_strength", value)

	

func _on_color_picker_button_popup_closed():
	creature.dying_colour = $ColorPickerButton.color


func _on_hat_btn_button_down():
	creature.find_child('Hat').visible = !creature.find_child('Hat').visible


func _on_glasses_btn_button_down():
	creature.find_child('Glasses').visible = !creature.find_child('Glasses').visible
