class_name UiTheme extends Resource
## A custom resource to store the information of a single UI theme.
@export var theme_name: String
@export var hint: String
@export var screen_tint: Color
## how much the screen tint will affect the bg sun rays
@export var screen_tint_ray_intensity: float
@export var food_btn: Texture2D
@export var food_btn_pressed: Texture2D
@export var act_btn: Texture2D
@export var act_btn_pressed: Texture2D
@export var setting_btn: Texture2D
@export var setting_btn_pressed: Texture2D
@export var ui_overlay: Texture2D
@export var memory_ui: Texture2D
@export var totris_ui: Texture2D
@export var box_inverted: Texture2D
@export var box: Texture2D
@export var unlocked: bool
@export_category("Colours")
@export var primary: Color
@export var bg: Color
@export var outline: Color
