extends TextureButton

func _ready():
	var tween = create_tween().set_loops().set_ease(Tween.EASE_OUT_IN)
	var bitmap = BitMap.new()
	var image = texture_normal.get_image()
	bitmap.create_from_image_alpha(image)
	texture_click_mask = bitmap
	tween.tween_property($".", "scale", Vector2(1.125, 1.05), 1)
	tween.tween_property($".", "scale", Vector2(1, .8), 1)
