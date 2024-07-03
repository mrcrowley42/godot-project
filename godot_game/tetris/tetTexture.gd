extends AnimatedSprite2D

const TOP = 0
const BOTTOM = 1
const LEFT = 2
const RIGHT = 3

var allowedTets = ['l_a', 'l_b', 'long', 'skew_a', 'skew_b', 'square', 't']
## tet normals define square allowance on sides for each frame of each tetromino (needed since every texture is a square)
## based on: https://strategywiki.org/wiki/Tetris/Rotation_systems
var tetNormals = {
	allowedTets[0]: {0: "0100", 1: "0010", 2: "1000", 3: "0001"},
	allowedTets[1]: {0: "1000", 1: "0001", 2: "0100", 3: "0010"},
	allowedTets[2]: {0: "1200", 1: "0021", 2: "1100", 3: "0011"},
	allowedTets[3]: {},
	allowedTets[4]: {},
	allowedTets[5]: {},
	allowedTets[6]: {0: "1000", 1: "0001", 2: "0100", 3: "0010"}
}

func get_normal(direction: int) -> int:
	return int(tetNormals[animation][frame][direction])

func get_size() -> Vector2:
	return sprite_frames.get_frame_texture(animation, frame).get_size()

## clips size based on tet normals
func get_clipped_size() -> Vector2:
	return get_size() - Vector2(30, 30) * Vector2(
		get_normal(LEFT) + get_normal(RIGHT),
		get_normal(TOP) + get_normal(BOTTOM)
	)

## clip position to centre of tet normals (centre of clipped size)
func get_clipped_pos():
	var offset = Vector2(15, 15) * Vector2(
		get_normal(LEFT) + -get_normal(RIGHT),
		get_normal(TOP) + -get_normal(BOTTOM)
	)
	return position + offset

func set_anim(anim):
	assert(anim in allowedTets)
	set_animation(anim)

func advance_frame():
	frame = (frame + 1) % sprite_frames.get_frame_count(animation)

func rewind_frame():
	frame -= 1 if frame > 0 else -sprite_frames.get_frame_count(animation)
