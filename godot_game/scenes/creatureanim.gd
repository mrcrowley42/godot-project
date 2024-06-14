extends AnimatedSprite2D

func _process(_delta):
	self.sprite_frames.set_animation_speed(
		'idle', clampf((4 * (1000/ $"..".health)),4,20))
