extends Node2D

@onready var canvas = find_child("CanvasLayer")
@onready var texture = find_child("Texture")

var boardSize: Vector2
var squareSize: Vector2 = Vector2(30, 30)
var resting = false

const L_LERP_START = 5
const A_LERP_START = 5  # rotation
var l_start_time = null
var a_start_time = null

## snap given vec to grid of squareSize
func snap_to_grid(vec: Vector2):
	var topLeft = vec - texture.get_size() / 2
	var amount = Vector2(
			int(topLeft.x) % int(squareSize.x), 
			int(topLeft.y) % int(squareSize.y)
		)
	texture.position = vec - amount
	texture.position.y += squareSize.y * texture.get_normal(texture.BOTTOM)

func init(piece: String, bPos: Vector2, bSize: Vector2):
	boardSize = bSize
	canvas.offset = bPos
	texture.set_anim(piece)

## performs wall-kick based on clipped size & pos of tetmomino
func x_correction():
	var offset_pos = texture.get_clipped_pos()
	var cSize_x = texture.get_clipped_size().x / 2
	var cSize_x_r = boardSize.x - cSize_x
	var isClipped = texture.get_size().x / 2 != cSize_x
	
	if cSize_x > offset_pos.x:
		texture.position.x = texture.position.x + squareSize.x if isClipped else cSize_x
	elif cSize_x_r < offset_pos.x:
		texture.position.x = texture.position.x - squareSize.x if isClipped else cSize_x_r

## avoid clipping into other resting tetrominoes
func y_correction():
	pass

func gravity_tick():
	texture.position.y += squareSize.y
	y_correction()

func move_left():
	texture.position.x -= squareSize.x
	x_correction()
	perform_linear_lerp(1)

func move_right():
	texture.position.x += squareSize.x
	x_correction()
	perform_linear_lerp(-1)

func rotate_clockwise():
	texture.advance_frame()
	x_correction()
	y_correction()
	perform_angular_lerp(1)

func rotate_counter_clockwise():
	texture.rewind_frame()
	x_correction()
	y_correction()
	perform_angular_lerp(-1)

func perform_linear_lerp(direction):
	texture.set_offset(Vector2(L_LERP_START * direction, 0))
	l_start_time = Time.get_unix_time_from_system()

func perform_angular_lerp(direction):
	pass

## progress various lerps
func _process(_delta):
	pass
