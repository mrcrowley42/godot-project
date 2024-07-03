extends AnimatedSprite2D

const TOP = 0
const BOTTOM = 1
const LEFT = 2
const RIGHT = 3

var allowedAnimations = ['l_a', 'l_b', 'long', 'skew_a', 'skew_b', 'square', 't']
var tetNormals = {
	"t": {0: "1000", 1: "0001", 2: "0100", 3: "0010"}
}

func get_normal(direction: int) -> int:
	return int(tetNormals[animation][frame][direction])

func get_size() -> Vector2:
	return sprite_frames.get_frame_texture(animation, frame).get_size()

func set_anim(anim):
	assert(anim in allowedAnimations)
	set_animation(anim)

func advance_frame():
	frame = (frame + 1) % sprite_frames.get_frame_count(animation)

func rewind_frame():
	frame -= 1 if frame > 0 else -sprite_frames.get_frame_count(animation)
