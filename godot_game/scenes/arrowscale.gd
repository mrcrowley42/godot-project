extends Sprite2D


func _ready():
	var tween = create_tween().set_loops().set_ease(Tween.EASE_OUT_IN)
	
	tween.tween_property($".","scale",Vector2(1.25,1.1), 1)
	tween.tween_property($".","scale",Vector2(1,.8), 1)
