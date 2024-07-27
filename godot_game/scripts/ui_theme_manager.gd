extends ScriptNode

@export var themes: Array[UiTheme]
@onready var screen_colours = %ScreenColours
@onready var food_btn = %FoodButton
@onready var act_btn = %ActButton
@onready var setting_btn = %SettingButton
@onready var ui_overlay = %UI_Overlay

## The current index in the list of themes.
var i: int

func _ready():
	screen_colours.color = themes[i].screen_tint
	
func change_texture(shift=0):
	self.i = Helpers.wrap_index(themes, i, shift)
	ui_overlay.texture = themes[i].ui_overlay
	screen_colours.color = themes[i].screen_tint
	food_btn.texture_normal = themes[i].food_btn
	food_btn.texture_pressed = themes[i].food_btn_pressed
	act_btn.texture_normal = themes[i].act_btn
	act_btn.texture_pressed = themes[i].act_btn_pressed
	setting_btn.texture_normal = themes[i].setting_btn
	setting_btn.texture_pressed = themes[i].setting_btn_pressed

func cycle_forward():
	change_texture(1)

func cycle_backwards():
	change_texture(-1)

func save() -> Dictionary:
	return {"section": Globals.UI_SECTION, "Theme": abs(self.i)}

func load(data):
	if "Theme" in data.keys():
		self.i = int(data["Theme"])
	change_texture()

func get_current_theme():
	return themes[i]
