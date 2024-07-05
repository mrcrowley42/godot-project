extends AnimatedSprite2D

signal collided

const TOP = 0
const BOTTOM = 1
const LEFT = 2
const RIGHT = 3

const SWITCH = -1
const ROT = 9

const ALLOWED_TETS = ['l_a', 'l_b', 'long', 'skew_a', 'skew_b', 'square', 't']
## tet normals define square allowance on sides for each frame of each tetromino (needed since every texture is a square)
## based on: https://strategywiki.org/wiki/Tetris/Rotation_systems
const TET_NORMALS = {
	ALLOWED_TETS[0]: {0: "0100", 1: "0010", 2: "1000", 3: "0001", ROT: 90},
	ALLOWED_TETS[1]: {0: "1000", 1: "0001", 2: "0100", 3: "0010", ROT: 90},
	ALLOWED_TETS[2]: {0: "1200", 1: "0021", ROT: SWITCH},
	ALLOWED_TETS[3]: {0: "1000", 1: "0010", ROT: -90},
	ALLOWED_TETS[4]: {0: "1000", 1: "0010", ROT: -90},
	ALLOWED_TETS[5]: {0: "0000", ROT: 0},
	ALLOWED_TETS[6]: {0: "1000", 1: "0001", 2: "0100", 3: "0010", ROT: 90}
}

var base_pos: Vector2
var relative_pos: Vector2 = Vector2(0, 0)
var collision_area: Area2D;

func get_normal(direction: int) -> int:
	return int(TET_NORMALS[animation][frame][direction])

func get_rot_addition() -> int:
	return int(TET_NORMALS[animation][ROT])

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
	return relative_pos + (Vector2(15, 15) * Vector2(
		get_normal(LEFT) - get_normal(RIGHT),
		get_normal(TOP) - get_normal(BOTTOM)
	))

func get_all_collision_pos():
	# rotate each shapes position by rotation_degrees around 0, 0 to get correct position
	var rotate = func(point: Vector2, degrees) -> Vector2:
		var radians = degrees * (PI / 180)
		var out = Vector2(point)
		out.x = cos(radians) * point.x - sin(radians) * point.y
		out.y = sin(radians) * point.x + cos(radians) * point.y
		return out
	
	var p = []
	for shape: CollisionShape2D in collision_area.get_children():
		if !shape.disabled:
			p.append(Vector2(base_pos + relative_pos + rotate.call(shape.position, collision_area.rotation_degrees)))
	return p

func set_anim(anim):
	assert(anim in ALLOWED_TETS)
	set_animation(anim)
	collision_area = find_child(anim)
	collision_area.visible = true

func set_x(x):
	set_pos(Vector2(x, relative_pos.y))

func set_y(y):
	set_pos(Vector2(relative_pos.x, y))

func add_x(x):
	set_pos(Vector2(relative_pos.x + x, relative_pos.y))

func add_y(y):
	set_pos(Vector2(relative_pos.x, relative_pos.y + y))

func set_pos(vec: Vector2):
	relative_pos = vec
	correct_pos()

func correct_pos():
	position = base_pos + relative_pos

func set_x_offset(val):
	offset.x = val

func set_angle(rad):
	rotation = rad

func update_collision():
	if get_rot_addition() == SWITCH:  # special case for long
		for c in collision_area.get_children():
			c.disabled = !c.disabled
	else:  # rotate normally
		collision_area.rotation_degrees = get_rot_addition() * frame

func get_frame_count() -> int:
	return int(sprite_frames.get_frame_count(animation))

func advance_frame():
	frame = (frame + 1) % get_frame_count()
	update_collision()

func rewind_frame():
	frame -= 1 if frame > 0 else -get_frame_count()
	update_collision()
