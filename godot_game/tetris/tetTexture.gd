extends AnimatedSprite2D

const TOP = 0
const BOTTOM = 1
const LEFT = 2
const RIGHT = 3

const ALLOWED_TETS = ['l_a', 'l_b', 'long', 'skew_a', 'skew_b', 'square', 't']
## tet normals define square allowance on sides for each frame of each tetromino (needed since every texture is a square)
## based on: https://strategywiki.org/wiki/Tetris/Rotation_systems
const TET_NORMALS = {
	ALLOWED_TETS[0]: {0: "0100", 1: "0010", 2: "1000", 3: "0001"},
	ALLOWED_TETS[1]: {0: "1000", 1: "0001", 2: "0100", 3: "0010"},
	ALLOWED_TETS[2]: {0: "1200", 1: "0021"},
	ALLOWED_TETS[3]: {0: "1000", 1: "0010"},
	ALLOWED_TETS[4]: {0: "1000", 1: "0010"},
	ALLOWED_TETS[5]: {0: "0000"},
	ALLOWED_TETS[6]: {0: "1000", 1: "0001", 2: "0100", 3: "0010"}
}

func get_normal(direction: int) -> int:
	return int(TET_NORMALS[animation][frame][direction])

func get_size() -> Vector2:
	return sprite_frames.get_frame_texture(animation, frame).get_size()

## clips size based on tet normals
func get_clipped_size() -> Vector2:
	return get_size() - Vector2(30, 30) * Vector2(
		get_normal(LEFT) + get_normal(RIGHT),
		get_normal(TOP) + get_normal(BOTTOM)
	)

## clip position to centre of tet normals (centre of clipped size)
func get_clipped_pos() -> Vector2:
	return position + (Vector2(15, 15) * Vector2(
		get_normal(LEFT) - get_normal(RIGHT),
		get_normal(TOP) - get_normal(BOTTOM)
	))

func set_anim(anim):
	assert(anim in ALLOWED_TETS)
	set_animation(anim)

func set_x_offset(val):
	offset.x = val

func advance_frame():
	frame = (frame + 1) % sprite_frames.get_frame_count(animation)

func rewind_frame():
	frame -= 1 if frame > 0 else -sprite_frames.get_frame_count(animation)
