class_name UiThemeManager extends ScriptNode

## List of available UI themes.
var themes = preload("res://resources/ui_theme_list.tres").theme_list

@onready var food_btn = %FoodButton
@onready var act_btn = %ActButton
@onready var setting_btn = %SettingButton
@onready var ui_overlay = %UI_Overlay
@onready var bg = %BG

## The current index in the list of themes.
var i: int
var current_theme: UiTheme

var theme_dict = Dictionary()

func _ready() -> void:
	for theme in themes:
		theme_dict[theme.theme_name] = theme

## Moves the index of the currently selected theme by [param shift] if a value
## is provided, then loads the colours and textures of the current theme.
func update_theme(shift: int = 0) -> void:
	if shift:
		self.i = Helpers.wrap_index(themes, i, shift)
	ui_overlay.texture = themes[i].ui_overlay
	bg.material.set("shader_parameter/tint_colour", themes[i].screen_tint)
	food_btn.texture_normal = themes[i].food_btn
	food_btn.texture_pressed = themes[i].food_btn_pressed
	act_btn.texture_normal = themes[i].act_btn
	act_btn.texture_pressed = themes[i].act_btn_pressed
	setting_btn.texture_normal = themes[i].setting_btn
	setting_btn.texture_pressed = themes[i].setting_btn_pressed


func cycle_forward() -> void:
	update_theme(1)


func cycle_backwards() -> void:
	update_theme(-1)


func get_current_theme() -> UiTheme:
	return themes[i]


func save() -> Dictionary:
	return {"section": Globals.UI_SECTION, "Theme": current_theme.theme_name if current_theme else ""}

func load(data) -> void:
	if data.has("Theme"):
		set_theme(theme_dict[data["Theme"]])
	
func set_theme(ui_theme):
	current_theme = ui_theme
	ui_overlay.texture = ui_theme.ui_overlay
	bg.material.set("shader_parameter/tint_colour", ui_theme.screen_tint)
	food_btn.texture_normal = ui_theme.food_btn
	food_btn.texture_pressed = ui_theme.food_btn_pressed
	act_btn.texture_normal = ui_theme.act_btn
	act_btn.texture_pressed = ui_theme.act_btn_pressed
	setting_btn.texture_normal = ui_theme.setting_btn
	setting_btn.texture_pressed = ui_theme.setting_btn_pressed
