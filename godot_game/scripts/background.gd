class_name Background extends ScriptNode

@onready var bg_sprite: Sprite2D = find_child("BG")
@onready var bg_light_shader: ColorRect = find_child("LightShader")
@onready var bg_tint: ColorRect = find_child("ThemeTint")

const SECS_PER_DAY = 86400
var tint_opacity: float = 30.0

# time values
var day_percent: float = 0.0

func _ready():
	update_bg()

func update_bg():
	var time = Time.get_time_dict_from_system()
	var seconds_today = (time.hour * 3600) + (time.minute * 60) + time.second
	day_percent = float(seconds_today) / float(SECS_PER_DAY)
	print(day_percent)

func _process(_delta):
	bg_tint.color = %ScreenColours.color
	bg_tint.color.a = tint_opacity / 255.0

func _on_bg_update_timeout():
	update_bg()
