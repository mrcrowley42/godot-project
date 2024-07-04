extends Node2D

signal placed

@onready var canvas = find_child("CanvasLayer")
@onready var body = find_child("Body")

var boardSize: Vector2
var all_pieces = []
var squareSize: Vector2 = Vector2(30, 30)
var resting: bool = false

const LERP_TIME = 0.05;  # 0.05
const L_LERP_START = 5
const A_LERP_START = 0.1  # radians
var l_direction = 0
var a_direction = 0
var l_start_time = null
var a_start_time = null
var l_end_time = null
var a_end_time = null

## snap given vec to grid of squareSize
func snap_to_grid(vec: Vector2):
	var topLeft = vec - body.get_size() / 2
	var amount = Vector2(
			int(topLeft.x) % int(squareSize.x), 
			int(topLeft.y) % int(squareSize.y)
		)
	body.set_pos(vec - amount)
	body.add_y(squareSize.y * body.get_normal(body.BOTTOM))

func init(piece: String, b_pos: Vector2, b_size: Vector2, previous_pieces):
	boardSize = b_size
	body.base_pos = b_pos
	body.set_anim(piece)
	all_pieces = previous_pieces

## performs wall-kick based on clipped size & pos of tetmomino
func x_correction():
	var offset_pos = body.get_clipped_pos()
	var c_size_x = body.get_clipped_size().x / 2
	var c_size_x_r = boardSize.x - c_size_x
	var is_clipped = body.get_size().x / 2 != c_size_x
	
	if c_size_x > offset_pos.x:
		body.set_x(body.relative_pos.x + squareSize.x if is_clipped else c_size_x)
	elif c_size_x_r < offset_pos.x:
		body.set_x(body.relative_pos.x - squareSize.x if is_clipped else c_size_x_r)
	# push away from a collision

## avoid clipping into other resting tetrominoes
func y_correction():
	# check for collision & move up
	# limit to 5 corrections before automatically placing
	pass

func place_tet():
	resting = true
	placed.emit()

func gravity_tick():
	body.add_y(squareSize.y)
	if check_for_collision():
		body.add_y(-squareSize.y)  # revert gravity
		place_tet()

func move_left():
	body.add_x(-squareSize.x)
	x_correction()
	perform_linear_lerp(1)

func move_right():
	body.add_x(squareSize.x)
	x_correction()
	perform_linear_lerp(-1)

func rotate_clockwise():
	body.advance_frame()
	x_correction()
	y_correction()
	perform_angular_lerp(-1)

func rotate_counter_clockwise():
	body.rewind_frame()
	x_correction()
	y_correction()
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
func advance_lerp(s_time, e_time, direction, start, offset=false) -> bool:
	if s_time != null:
		var t = Time.get_unix_time_from_system()
		var perc = (t - s_time) / (e_time - s_time)
		if perc >= 1:
			return false
		var sub = start * perc
		sub = sub if direction > 0 else -sub
		if offset:
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

## loop through all previous peices and check for a collision
func check_for_collision() -> bool:
	# godot's collision detection is stupid and allows a few frames to slip past before triggering a collision signal
	# meaning the collision is out-of-date and draws the tet in the wrong position for a few microseconds
	# so i've resorted to making my own manual checks :pensive:
	var check_rects = func(r1: Rect2, r2: Rect2):
		var r1_size_h = r1.size / 2
		var r2_size_h = r2.size / 2
		var normal = (r2.position - r1_size_h) - (r1.position - r2_size_h)  # allows for different size boxes
		var x_overlap = r1_size_h.x + r2_size_h.x - abs(normal.x)
		if x_overlap >= 0:
			var y_overlap = r1_size_h.y + r2_size_h.y - abs(normal.y)
			return y_overlap >= 0
		return false
	
	for rect in body.get_all_rect_bounds():
		for piece in all_pieces:
			var coll = false
			
			if piece.name == "Ground":  # special case
				var c = piece.get_child(0)
				coll = check_rects.call(rect, Rect2(c.position - c.shape.size / 2, c.shape.size))
			else:  # normal tet
				for other_rect in piece.body.get_all_rect_bounds():
					coll = check_rects.call(rect, other_rect)
			
			if coll:
				return true
	return false
