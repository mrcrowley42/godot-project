class_name Background extends ScriptNode

@export_group("BG Shader")
@export var upper_colour_curve: Gradient
@export var lower_colour_curve: Gradient
@export var ray_colour_curve: Gradient
@export_subgroup("BG")
@export var bg_strength_curve: Curve
@export var bg_time_tint_curve: Curve
@export_subgroup("Light Rays")
@export var ray_strength_curve: Curve
@export var ray_length_curve: Curve
@export var ray_direction_curve: Curve
@export_subgroup("Heavenly Bodies")  # >:)
@export var sun_x: Curve
@export var sun_y: Curve
@export var moon_x: Curve
@export var moon_y: Curve

@onready var bg_sprite: Sprite2D = find_child("BG")
@onready var shader_rect: ColorRect = find_child("LightShader")
@onready var time_tine: CanvasModulate = find_child("TimeTint")


const SECS_PER_DAY = 86400
const MOON_PHASES: int = 12
const MOON_PHASE_VALUES = {
	0: [.09, 0],
	1: [.07, 0],
	2: [.055, 0],
	3: [.045, 0],
	4: [.035, 0],
	5: [.02, 0],
	6: [.0, 0],
	7: [.02, 180],
	8: [.035, 180],
	9: [.045, 180],
	10: [.055, 180],
	11: [.07, 180]
}

var time_div = 1
var is_progressing: bool = true  # for debug window to control
var day_percent: float = 0.0
var moon_phase = 0

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
	
	shader_rect.material.set("shader_parameter/sun_pos", Vector2(1. - sun_x.sample(day_percent), 1. - sun_y.sample(day_percent)))
	shader_rect.material.set("shader_parameter/moon_pos", Vector2(1. - moon_x.sample(day_percent), 1. - moon_y.sample(day_percent)))
	
	shader_rect.material.set("shader_parameter/m_shadow_dist", MOON_PHASE_VALUES[moon_phase][0])
	shader_rect.material.set("shader_parameter/m_shadow_rot", MOON_PHASE_VALUES[moon_phase][1])

## clamped value
func change_day_progress(value: float, from_debug = false):
	is_progressing = !from_debug
	day_percent = min(1., max(0., value))
	update_light_shader()

func set_moon_phase():
	@warning_ignore("narrowing_conversion")  ## shut up
	var today = Time.get_datetime_dict_from_system()
	var current: int = Time.get_unix_time_from_datetime_dict({"year": today.year, "month": today.month, "day": today.day})
	@warning_ignore("integer_division")
	var start: int = Time.get_unix_time_from_datetime_dict({"year": today.year, "month": 1, "day": 1})
	@warning_ignore("integer_division")
	var day_of_year: int = floor((current - start) / SECS_PER_DAY)
	moon_phase = day_of_year % MOON_PHASES

func update_time():
	if is_progressing:
		set_moon_phase()
		var time = Time.get_time_dict_from_system()
		@warning_ignore("integer_division")  # these are intentional int divisions
		var seconds_today = ((time.hour * 3600) + (time.minute * 60) + time.second) % (SECS_PER_DAY / int(time_div))
		@warning_ignore("integer_division")
		change_day_progress(float(seconds_today) / float(SECS_PER_DAY / time_div))

func toggle_debug(value: bool):
	shader_rect.material.set("shader_parameter/debug_mode", value)

func _ready():
	shader_rect.color = Color(.0, .0, .0, .0)
	update_time()

func _on_bg_update_ticker_timeout():
	update_time()
