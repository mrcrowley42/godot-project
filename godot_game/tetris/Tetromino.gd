extends Node2D

signal placed

@onready var canvas = find_child("CanvasLayer")
@onready var body = find_child("Body")

var board_size: Vector2
var all_pieces = []
var square_size: Vector2 = Vector2(30, 30)
var resting: bool = false

## ANIMATION LERP VALUES 
const LERP_TIME = 0.05;  # 0.05
const L_LERP_START = 5
const A_LERP_START = 0.1  # radians
var l_direction = 0
var a_direction = 0
var l_start_time = null
var a_start_time = null
var l_end_time = null
var a_end_time = null

## snap given vec to grid of square_size
func snap_to_grid(vec: Vector2):
	var top_left = vec - body.get_size() / 2
	var amount = Vector2(
			int(top_left.x) % int(square_size.x), 
			int(top_left.y) % int(square_size.y)
		)
	body.set_pos(vec - amount)
	body.add_y(square_size.y * body.get_normal(body.BOTTOM))

func init(piece: String, b_pos: Vector2, b_size: Vector2, previous_pieces):
	board_size = b_size
	body.base_pos = b_pos
	body.set_anim(piece)
	all_pieces = previous_pieces

## performs wall-kick based on clipped size & pos of tetmomino
func x_wall_correction():
	var offset_pos = body.get_clipped_pos()
	var c_size_x = body.get_clipped_size().x / 2
	var c_size_x_r = board_size.x - c_size_x
	var is_clipped = body.get_size().x / 2 != c_size_x
	
	if c_size_x > offset_pos.x:
		body.set_x(body.relative_pos.x + square_size.x if is_clipped else c_size_x)
	elif c_size_x_r < offset_pos.x:
		body.set_x(body.relative_pos.x - square_size.x if is_clipped else c_size_x_r)

## avoid clipping other tetrominoes or the walls
func general_correction():
	var collision: CollisionInfo = check_for_collision()
	if collision:
		body.add_x(square_size.x * collision.x_direction)
		
		# special case for left side of long block: move again if still colliding in the same direction
		if collision.x_direction > 0 and collision.incident_body.body.animation == "long":
			var other_coll = check_for_collision()
			if other_coll and other_coll.x_direction == collision.x_direction:
				body.add_x(square_size.x * collision.x_direction)
		
		x_wall_correction()  # tolerate tet clipping over wall clipping
		if check_for_collision():  # if colliding again, block is being squashed horizontally, adjust y
			y_correction(true)
	else:
		x_wall_correction()

## avoid clipping into other resting tetrominoes (limits to 5 corrections / tet)
func y_correction(already_collising=false):
	if already_collising or check_for_collision():
		body.add_y(-square_size.y)  # move up until no longer colliding
		y_correction()

func place_tet():
	resting = true
	placed.emit()

func gravity_tick():
	body.add_y(square_size.y)
	
	if check_for_collision():
		body.add_y(-square_size.y)  # revert gravity
		place_tet()

func move_left():
	body.add_x(-square_size.x)
	if check_for_collision():
		body.add_x(square_size.x)
	
	x_wall_correction()
	perform_linear_lerp(1)

func move_right():
	body.add_x(square_size.x)
	if check_for_collision():
		body.add_x(-square_size.x)
	
	x_wall_correction()
	perform_linear_lerp(-1)

func rotate_clockwise():
	body.advance_frame()
	general_correction()
	perform_angular_lerp(-1)

func rotate_counter_clockwise():
	body.rewind_frame()
	general_correction()
	perform_angular_lerp(1)

func perform_linear_lerp(direction):
	l_direction = direction
	body.set_x_offset(L_LERP_START * direction)
	l_start_time = Time.get_unix_time_from_system()
	l_end_time = l_start_time + LERP_TIME

func perform_angular_lerp(direction):
	a_direction = direction
	body.set_angle(A_LERP_START * direction)
	a_start_time = Time.get_unix_time_from_system()
	a_end_time = a_start_time + LERP_TIME

## returns whether lerp progressed
func advance_lerp(s_time, e_time, direction, start, on_offset=false) -> bool:
	if s_time != null:
		var t = Time.get_unix_time_from_system()
		var perc = (t - s_time) / (e_time - s_time)
		if perc >= 1:
			return false
		var sub = start * perc
		sub = sub if direction > 0 else -sub
		if on_offset:
			body.set_x_offset((start * direction) - sub)
		else:
			body.set_angle((start * direction) - sub)
		return true
	return false

## progress various lerps
func _process(_delta):
	var advance_l = advance_lerp(l_start_time, l_end_time, l_direction, L_LERP_START, true)
	var advance_a = advance_lerp(a_start_time, a_end_time, a_direction, A_LERP_START)
	
	if !advance_l:
		body.set_x_offset(0)
		l_start_time = null
		l_end_time = null
	if !advance_a:
		body.set_angle(0)
		a_start_time = null
		a_end_time = null

## loop through all previous peices and check for an overlap. returns collision info or null
func check_for_collision():
	# godot's collision detection is stupid and allows a few frames to slip past before triggering a collision signal
	# meaning the collision is out-of-date and draws the tet in the wrong position for a few microseconds
	# so i've resorted to making my own manual checks :pensive:
	for pos in body.get_all_collision_pos():
		for piece in all_pieces:
			var is_ground = piece.name == "Ground"
			var points = piece.get_all_positions() if is_ground else piece.body.get_all_collision_pos()
			for other_pos in points:
				if pos == other_pos:
					# generate collision info
					var c_info: CollisionInfo = CollisionInfo.new()
					if !is_ground:
						c_info.incident_body = piece
						c_info.x_direction = int((body.relative_pos.x - piece.body.relative_pos.x) > 0)
						c_info.x_direction = (c_info.x_direction - 1) + c_info.x_direction
					return c_info
	return null

## small class to hold a few collision values
class CollisionInfo:
	var incident_body;  # Tetromino
	var x_direction;  # < -1 or 1 >
