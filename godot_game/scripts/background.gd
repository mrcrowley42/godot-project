class_name Background extends ScriptNode

@export_group("BG Shader")
@export var upper_colour_curve: Gradient
@export var lower_colour_curve: Gradient
@export var ray_colour_curve: Gradient
@export_subgroup("BG")
@export var bg_strength_curve: Curve
@export_subgroup("Light Rays")
@export var ray_strength_curve: Curve
@export var ray_length_curve: Curve
@export var ray_direction_curve: Curve

@onready var bg_sprite: Sprite2D = find_child("BG")
@onready var shader_rect: ColorRect = find_child("LightShader")
@onready var bg_tint: ColorRect = find_child("ThemeTint")

const SECS_PER_DAY = 86400

var tint_opacity: float = .1
var is_progressing: bool = true  # for debug window to control
var day_percent: float = 0.0

## gradient idk:
## https://www.figma.com/community/file/967898387862224533/sky-gradient-library

## update values along curves
func update_light_shader():
	shader_rect.material.set("shader_parameter/upper_colour", upper_colour_curve.sample(day_percent))
	shader_rect.material.set("shader_parameter/lower_colour", lower_colour_curve.sample(day_percent))
	shader_rect.material.set("shader_parameter/ray_colour", ray_colour_curve.sample(day_percent))
	
	shader_rect.material.set("shader_parameter/bg_strength", bg_strength_curve.sample(day_percent))
	
	shader_rect.material.set("shader_parameter/ray_strength", ray_strength_curve.sample(day_percent))
	shader_rect.material.set("shader_parameter/ray_length", ray_length_curve.sample(day_percent))
	shader_rect.material.set("shader_parameter/ray_direction", ray_direction_curve.sample(day_percent))

## clamped value
func change_day_progress(value: float, from_debug = false):
	is_progressing = !from_debug
	day_percent = min(1., max(0., value))
	update_light_shader()

func update_time():
	if is_progressing:
		var time = Time.get_time_dict_from_system()
		var seconds_today = (time.hour * 3600) + (time.minute * 60) + time.second
		change_day_progress(float(seconds_today) / float(SECS_PER_DAY))

func toggle_debug(value: bool):
	shader_rect.material.set("shader_parameter/debug_mode", value)

func _ready():
	shader_rect.color = Color(.0, .0, .0, .0)
	update_time()

func _process(_delta):
	var col = %ScreenColours.color
	col.a = tint_opacity
	bg_tint.material.set("shader_parameter/tint_colour", col)
	bg_sprite.material.set("shader_parameter/tint_colour", %ScreenColours.color)

func _on_bg_update_ticker_timeout():
	update_time()
