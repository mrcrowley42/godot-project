class_name Background extends ScriptNode

@export_group("BG Shader")
@export var upper_colour_curve: Gradient
@export var lower_colour_curve: Gradient
@export var ray_colour_curve: Gradient
@export_subgroup("BG")
@export var bg_strength_curve: Curve
@export var bg_fade_curve: Curve
@export_subgroup("Light Rays")
@export var ray_strength_curve: Curve
@export var ray_length_curve: Curve
@export var ray_direction_curve: Curve

@onready var bg_sprite: Sprite2D = find_child("BG")
@onready var shader_rect: ColorRect = find_child("LightShader")
@onready var bg_tint: ColorRect = find_child("ThemeTint")

const SECS_PER_DAY = 86400

var tint_opacity: float = 30.0
var is_progressing: bool = true  # for debug window to control
var day_percent: float = 0.0

## gradient idk:
## https://www.figma.com/community/file/967898387862224533/sky-gradient-library

func update_bg():
	if is_progressing:
		var time = Time.get_time_dict_from_system()
		var seconds_today = (time.hour * 3600) + (time.minute * 60) + time.second
		day_percent = float(seconds_today) / float(SECS_PER_DAY)
	
	# ITS NOT SETTING FOR SOME REASOM
	shader_rect.material.set("shader_parameter/upper_colour", upper_colour_curve.sample(day_percent))
	shader_rect.material.set("shader_parameter/lower_colour", lower_colour_curve.sample(day_percent))
	shader_rect.material.set("shader_parameter/ray_colour", ray_colour_curve.sample(day_percent))
	print(day_percent)


func _ready():
	shader_rect.color = Color(.0, .0, .0, .0)
	update_bg()

func _process(_delta):
	bg_tint.color = %ScreenColours.color
	bg_tint.color.a = tint_opacity / 255.0

func _on_bg_update_timeout():
	update_bg()
