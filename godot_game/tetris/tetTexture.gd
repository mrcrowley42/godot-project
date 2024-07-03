extends AnimatedSprite2D


func get_size() -> Vector2:
	return self.sprite_frames.get_frame_texture(animation, frame).get_size()

