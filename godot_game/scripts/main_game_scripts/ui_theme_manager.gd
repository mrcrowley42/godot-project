class_name UiThemeManager extends ScriptNode

## List of available UI themes.
var themes = preload("res://resources/ui_theme_list.tres").theme_list
var fallback_theme = load("res://resources/ui_themes/green.tres")
@onready var food_btn = %FoodButton
@onready var act_btn = %ActButton
@onready var setting_btn = %SettingButton
@onready var ui_overlay = %UI_Overlay
@onready var bg = %BG
@onready var theme_btns = %ThemeBtns

## The current theme
var current_theme: UiTheme
## Stores themes to be retreived like so {theme.theme_name: theme}
var theme_dict = Dictionary()


func _ready() -> void:
	for theme in themes:
		theme_dict[theme.theme_name.to_lower()] = theme


func save() -> Dictionary:
	return {"section": Globals.UI_SECTION, "Theme": current_theme.theme_name if current_theme else ""}


## Load theme if one exists in cfg, use green if value can't be parsed.
func load(data) -> void:
	var fallback_name = fallback_theme.theme_name.to_lower()
	var theme_name = data["Theme"].to_lower() if data.has("Theme") else fallback_name
	var saved_theme = fallback_theme if not theme_dict.has(theme_name) else theme_dict[theme_name]
	set_theme(saved_theme)
	# Repairs broken cfg.
	DataGlobals.save_settings_data()
	# Preselect button for current theme.
	for theme_btn in theme_btns.get_children():
		if theme_btn.ui_theme.theme_name.to_lower() == saved_theme.theme_name.to_lower():
			theme_btn.set_pressed(true)
			break

## Updates the UI elements with the appropriate textures and colours, while also
## keeping track of the currently selected theme.
func set_theme(ui_theme) -> void:
	current_theme = ui_theme
	ui_overlay.texture = ui_theme.ui_overlay
	bg.material.set("shader_parameter/tint_colour", ui_theme.screen_tint)
	food_btn.texture_normal = ui_theme.food_btn
	food_btn.texture_pressed = ui_theme.food_btn_pressed
	act_btn.texture_normal = ui_theme.act_btn
	act_btn.texture_pressed = ui_theme.act_btn_pressed
	setting_btn.texture_normal = ui_theme.setting_btn
	setting_btn.texture_pressed = ui_theme.setting_btn_pressed
