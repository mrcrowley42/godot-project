extends Node2D

class_name Tetromino

signal placed
signal remove_piece

const SMALL_SCALE = Vector2(0.5, 0.5)
const SQUARE_SIZE: Vector2 = Vector2(30, 30)

@onready var body: TetBody = find_child("Body")
@onready var ghost = find_child("Ghost")

## TETROMINO STATES
var board_size: Vector2
var all_pieces = []
var y_corrections_left: int = 5
var gravity_skips_left: int = 5
var skip_next_gravity: bool = false
var resting: bool = false

## ANIMATION LERP VALUES 
const LERP_TIME = 0.05;
const L_LERP_START = 5  # linear
const A_LERP_START = 0.1  # angular

## snap given vec to grid of square_size
func snap_to_grid(vec: Vector2):
	var top_left = vec - body.get_size() / 2
	var remainder = Vector2(
			int(top_left.x) % int(SQUARE_SIZE.x), 
			int(top_left.y) % int(SQUARE_SIZE.y)
		)
	body.set_pos(vec - remainder)
	body.add_y(SQUARE_SIZE.y * body.get_normal(body.BOTTOM))  # squash white space at bottom of image

func init(piece: String, b_pos: Vector2, b_size: Vector2, previous_pieces):
	board_size = b_size
	body.base_pos = b_pos
	body.setup_body(piece, ghost)
	all_pieces = previous_pieces
	body.no_collisions.connect(no_more_collisions)

## call before initialising tet
func make_variant(type: String):
	assert(type in body.VARIANT_VALUES.keys())
	body.current_variant = type

func place_tet(from_instant=false):
	body.place_body()
	resting = true
	placed.emit(from_instant)

## Wrapper function to be used to call any movement function. Allows more time to move last second if about to place
func perform_movement(movement_func):
	var on_ghost_before = is_body_on_ghost()
	movement_func.call()
	if !on_ghost_before and is_body_on_ghost():
		skip_next_gravity = true

func gravity_tick():
	if skip_next_gravity and gravity_skips_left > 0:
		skip_next_gravity = false
		gravity_skips_left -= 1
		return
	
	body.add_y(SQUARE_SIZE.y)
	if check_for_collision():
		body.add_y(-SQUARE_SIZE.y)  # revert gravity
		place_tet()

func move_sideways(direction):
	var opposite_dir = {-1: 1, 1: -1}[direction]  # im lazy and dont feel like doing more maths here
	body.add_x(SQUARE_SIZE.x * direction)
	if check_for_collision():
		body.add_x(SQUARE_SIZE.x * opposite_dir)
	x_wall_correction()
	update_ghost()
	perform_linear_lerp(opposite_dir)

func rotate_piece(direction):
	(body.advance_frame if direction < 1 else body.rewind_frame).call()
	general_correction()
	update_ghost()
	perform_angular_lerp(direction)

## alters the given position so the tet appears centered on it
func centre_tet_on_position(pos: Vector2) -> Vector2:
	return pos - (body.get_clipped_pos() - body.relative_pos) / 2

func holding_tet(hold_pos: Vector2):
	body.position = centre_tet_on_position(hold_pos)
	body.scale = SMALL_SCALE
	ghost.visible = false

func stop_holding_tet():
	body.scale = Vector2(1, 1)
	ghost.visible = true

## used for only UI elements
func set_raw_position(pos: Vector2):
	body.position = centre_tet_on_position(pos)

## performs wall-kick based on clipped size & clipped pos of tetmomino
func x_wall_correction():
	var clipped_pos = body.get_clipped_pos()
	var left_limit = body.get_clipped_size().x / 2
	var right_limit = board_size.x - left_limit
	var has_been_clipped = body.get_size().x / 2 != left_limit
	
	if left_limit > clipped_pos.x:
		body.set_x(body.relative_pos.x + SQUARE_SIZE.x if has_been_clipped else left_limit)
	elif right_limit < clipped_pos.x:
		body.set_x(body.relative_pos.x - SQUARE_SIZE.x if has_been_clipped else right_limit)

## avoid clipping other tetrominoes or the walls
func general_correction():
	var collision = check_for_collision()
	if is_instance_of(collision, CollisionInfo):
		body.add_x(SQUARE_SIZE.x * collision.x_direction)
		
		# special case for left side of long block: move again if still colliding in the same direction
		if collision.x_direction > 0 and collision.incident_body.body.current_animation == "long":
			var other_coll = check_for_collision()
			if other_coll and other_coll.x_direction == collision.x_direction:
				body.add_x(SQUARE_SIZE.x * collision.x_direction)
	
	x_wall_correction()  # tolerate tetromino clipping over wall clipping
	# if colliding again, block is being squashed horizontally, fix y instead of x
	if check_for_collision():
		y_correction(true)
		y_corrections_left -= 1
		skip_next_gravity = true

## avoid clipping into other resting tetrominoes (limits to 5 corrections / tet)
## WARNING: recursive function
func y_correction(already_colliding=false):
	# check ONLY once if there is space below, and allow piece to slide in if there is space
	if already_colliding and check_for_collision(int(SQUARE_SIZE.y)) == null:
		body.add_y(SQUARE_SIZE.y)
		return
	
	if already_colliding or check_for_collision():
		body.add_y(-SQUARE_SIZE.y)  # move up until no longer colliding
		y_correction()
	elif !already_colliding and y_corrections_left <= 0:
		place_tet()  # too many y corrections, the player is abusing the system

func update_ghost():
	ghost.position = body.position
	while !check_for_collision(ghost.position.y - body.position.y):
		ghost.position.y += SQUARE_SIZE.y
	ghost.position.y -= SQUARE_SIZE.y  # revert back up

func is_body_on_ghost() -> bool:
	return ghost.position == body.position

## instantly teleport tet to ghost's y position & placem returns final, clipped position (not relative)
func drop_to_ghost() -> Vector2:
	update_ghost()  # sanity check the ghost
	body.add_y(ghost.position.y - body.position.y)
	var pos = body.get_clipped_pos(false)
	place_tet(true)
	return pos

func perform_linear_lerp(direction):
	body.set_x_offset(L_LERP_START * direction)
	body.perform_tween(body.TWEEN_OFFSET, Vector2(0, 0), LERP_TIME)

func perform_angular_lerp(direction):
	body.set_angle(A_LERP_START * direction)
	body.perform_tween(body.TWEEN_ROTATION, 0, LERP_TIME)

func get_all_ground_positions(ground):
	var points = []
	for shape: CollisionShape2D in ground.get_children():
		points.append(shape.position)
	return points

## loop through all previous peices and check for an overlap. returns collision info or null
func check_for_collision(y_offset=0):
	# godot's collision detection is stupid and allows a 1 frame to slip past before triggering a collision signal
	# meaning the collision is 1) out-of-date and 2) draws the piece in the wrong position for 1 frame
	# SO I MADE MY OWN RAAA
	for pos in body.get_raw_collision_points():
		pos.y += y_offset
		for other in all_pieces:
			var is_ground = other.name == "Ground"
			var points = get_all_ground_positions(other) if is_ground else other.body.get_raw_collision_points()
			
			for other_pos in points:
				if pos == other_pos:  # a collision hath occurred!
					var c_info: CollisionInfo = CollisionInfo.new()
					if !is_ground:  # generate collision info
						c_info.incident_body = other
						c_info.x_direction = int((body.relative_pos.x - other.body.relative_pos.x) > 0)
						c_info.x_direction += c_info.x_direction - 1  # converts to -1 or 1
					return c_info
	return null

class CollisionInfo:
	var incident_body = null;  # Tetromino
	var x_direction = 0;  # < -1 or 1 >

## called when the body finds it has no more collision points enabled
func no_more_collisions():
	all_pieces.erase(self)
	remove_piece.emit(self)
