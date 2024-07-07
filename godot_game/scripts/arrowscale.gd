extends TextureButton
var toggle = false
@onready var init_pos = %ActivityControls.position

var xoffset = 400

func _ready():
	#var tween = create_tween().set_loops().set_ease(Tween.EASE_OUT_IN)
	var bitmap = BitMap.new()
	var image = texture_normal.get_image()
	bitmap.create_from_image_alpha(image)
	texture_click_mask = bitmap
	#tween.tween_property($".","scale",Vector2(1.125,1.05), 1)
	#tween.tween_property($".","scale",Vector2(1,.8), 1)
	xoffset = init_pos.x- xoffset
	

func _on_button_down():
	var tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	
	toggle = !toggle
	if not toggle:
		tween.tween_property(%ActivityControls,"position", Vector2(xoffset,init_pos.y), .167)
	else:
		tween.tween_property(%ActivityControls,"position", Vector2(init_pos.x,init_pos.y), .167)
