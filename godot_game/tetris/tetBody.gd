extends AnimatedSprite2D

class_name TetBody

signal no_collisions

const TEXTURE_PATH = 'res://tetris/tetrominos/'
const TOP = 0
const BOTTOM = 1
const LEFT = 2
const RIGHT = 3

const SWITCH = -1  # special case for rotation
const ROTATION = 9

const ALLOWED_TETS = ['l_a', 'l_b', 'long', 'skew_a', 'skew_b', 'square', 't']
## tet normals define square allowance on sides for each frame of each tetromino (needed since every texture is a square)
## based on: https://strategywiki.org/wiki/Tetris/Rotation_systems
const TET_NORMALS = {
	ALLOWED_TETS[0]: {0: "0100", 1: "0010", 2: "1000", 3: "0001", ROTATION: 90},
	ALLOWED_TETS[1]: {0: "1000", 1: "0001", 2: "0100", 3: "0010", ROTATION: 90},
	ALLOWED_TETS[2]: {0: "1200", 1: "0021", ROTATION: SWITCH},
	ALLOWED_TETS[3]: {0: "1000", 1: "0010", ROTATION: -90},
	ALLOWED_TETS[4]: {0: "1000", 1: "0010", ROTATION: -90},
	ALLOWED_TETS[5]: {0: "0000", ROTATION: 0},
	ALLOWED_TETS[6]: {0: "1000", 1: "0001", 2: "0100", 3: "0010", ROTATION: 90}
}

var ghost: AnimatedSprite2D;
var base_pos: Vector2
var relative_pos: Vector2 = Vector2(0, 0)
var collision_area: Area2D;
var current_rotation = 0

func get_normal(direction: int) -> int:
	return int(TET_NORMALS[animation][frame][direction])

func get_rotation_addition() -> int:
	return int(TET_NORMALS[animation][ROTATION])

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

## converts all zeros to positive numbers
func negative_zero_correction(vec: Vector2) -> Vector2:
	return Vector2(
		vec.x if int(vec.x) != 0 else 0.0,
		vec.y if int(vec.y) != 0 else 0.0
	)

## rotate a position by current_rotation around 0, 0
func rotate_point(point: Vector2) -> Vector2:
	var radians = get_rotation_addition() * (PI / 180)
	var out = Vector2(point)
	out.x = cos(radians) * point.x - sin(radians) * point.y
	out.y = sin(radians) * point.x + cos(radians) * point.y
	return negative_zero_correction(out)

## returns with a list of (rotated) collision points for this tet
func get_raw_collision_points():
	var points = []
	for point: CollisionShape2D in collision_area.get_children():
		if !point.disabled:
			points.append(Vector2(base_pos + relative_pos + point.position))
	
	# has no more collision points, delete
	if len(points) == 0:
		no_collisions.emit()
	return points

## returns the collision node of the body at the given screen position
func get_coll_node_from_raw_position(raw_pos: Vector2):
	for node: CollisionShape2D in collision_area.get_children():
		if !node.disabled and raw_pos - (base_pos + relative_pos) == node.position:
			return node
	print("FAILED to find child collision point at position %s, %s" % [raw_pos.x, raw_pos.y])

func set_anim(anim):
	assert(anim in ALLOWED_TETS)
	set_animation(anim)
	collision_area = find_child(anim)
	collision_area.visible = true

func setup_ghost(ghost_node: AnimatedSprite2D):
	ghost = ghost_node
	ghost.visible = true
	ghost.set_animation(animation)

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

## rotates (or switches) the collision area based on its rotation addition
func update_collision():
	var addition = get_rotation_addition()
	if addition == SWITCH:  # special case for long
		for c in collision_area.get_children():
			c.disabled = !c.disabled
	else:  # rotate normally
		current_rotation = addition * frame
		print(current_rotation)
		for node: CollisionShape2D in collision_area.get_children():
			node.position = rotate_point(node.position)

func get_frame_count() -> int:
	return int(sprite_frames.get_frame_count(animation))

## rotates body clockwise
func advance_frame():
	frame = (frame + 1) % get_frame_count()
	ghost.frame = frame
	update_collision()

## rotates body counter clockwise
func rewind_frame():
	frame -= 1 if frame > 0 else -get_frame_count()
	ghost.frame = frame
	update_collision()

func spawn_singular_squares():
	collision_area.visible = true
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = load(TEXTURE_PATH + animation + '_single.png')
	sprite.z_index = -1  # so i can still see collisions
	
	for coll: CollisionShape2D in collision_area.get_children():
		if !coll.disabled:
			coll.add_child(sprite.duplicate())
	set_animation("empty")
