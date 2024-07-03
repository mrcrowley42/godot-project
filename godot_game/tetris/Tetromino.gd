extends Node2D

@onready var canvas = find_child("CanvasLayer")
@onready var texture = find_child("Texture")

var boardSize: Vector2
var squareSize: Vector2 = Vector2(30, 30)
var resting = false

## snap given vec to grid of squareSize
func snap_to_grid(vec: Vector2, size: Vector2) -> Vector2:
	var topLeft = vec - size / 2
	var amount = Vector2(
			int(topLeft.x) % int(squareSize.x), 
			int(topLeft.y) % int(squareSize.y)
		)
	return vec - amount

func init(piece: String, bPos: Vector2, bSize: Vector2):
	boardSize = bSize
	canvas.offset = bPos
	texture.set_anim(piece)

func place_tet(pos: Vector2):
	texture.position = snap_to_grid(pos, texture.get_size())

func x_correction(direction=0):
	var normL = squareSize.x * texture.get_normal(texture.LEFT) if direction < 0 else 0
	var normR = squareSize.x * texture.get_normal(texture.RIGHT) if direction > 0 else 0
	var x_w = texture.get_size().x / 2
	var bx_w = boardSize.x - x_w
	
	if x_w > texture.position.x:
		texture.position.x = x_w - normL
	elif bx_w < texture.position.x:
		texture.position.x = bx_w + normR

func gravity_tick():
	return
	texture.position.y += squareSize.y

func move_left():
	texture.position.x -= squareSize.x
	x_correction(-1)

func move_right():
	texture.position.x += squareSize.x
	x_correction(1)

func rotate_clockwise():
	texture.advance_frame()
	x_correction()

func rotate_counter_clockwise():
	texture.rewind_frame()
	x_correction()
