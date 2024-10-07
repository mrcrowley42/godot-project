extends Button

const colour = Color.CRIMSON

func _ready() -> void:
	for style in ["normal", "pressed", "hover", "disabled", "focus"]:
		var box = get_theme_stylebox(style)
		box.bg_color = colour
