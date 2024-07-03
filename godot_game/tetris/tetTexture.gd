extends AnimatedSprite2D

var allowedAnimations = ['l_a', 'l_b', 'long', 'skew_a', 'skew_b', 'square', 't']

func get_size() -> Vector2:
	return self.sprite_frames.get_frame_texture(animation, frame).get_size()

func set_anim(anim):
	assert(anim in allowedAnimations)
	set_animation(anim)

func advance_frame():
	self.frame = (self.frame + 1) % self.sprite_frames.get_frame_count(animation)

func rewind_frame():
	pass
