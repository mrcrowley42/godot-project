class_name Background extends ScriptNode

@onready var bg_sprite: Sprite2D = find_child("BG")
@onready var bg_light_shader: ColorRect = find_child("LightShader")
@onready var bg_tint: ColorRect = find_child("ThemeTint")

var tint_opacity: float = 30.0

# time values
var current_time: float = 0.0

func _ready():
	update_bg()

func update_bg():
	current_time = Time.get_unix_time_from_system()

func _process(_delta):
	bg_tint.color = %ScreenColours.color
	bg_tint.color.a = tint_opacity / 255.0

func _on_bg_update_timeout():
	update_bg()
