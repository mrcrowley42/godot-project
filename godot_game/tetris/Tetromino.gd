extends Node2D

@onready var canvas = find_child("CanvasLayer")
@onready var texture = find_child("Texture")

var boardSize: Vector2
var squareSize: Vector2 = Vector2(30, 30)
var resting = false

## snap given vec to grid of squareSize (always rounds down)
func snap_to_grid(vec: Vector2, size: Vector2) -> Vector2:
	var sMod = Vector2(
			int(size.x) % int(squareSize.x * 2), 
			int(size.y) % int(squareSize.y * 2)
		)  # find what needs moving based on size
	vec = Vector2(
			vec.x - (int(vec.x) % int(squareSize.x)), 
			vec.y - (int(vec.y) % int(squareSize.y))
		)  # round down to multiples of squareSize
	return vec - (squareSize / 2) * sMod.normalized()

func init(piece: String, bPos: Vector2, bSize: Vector2):
	boardSize = bSize
	canvas.offset = bPos
	texture.set_anim(piece)

func place_tet(pos: Vector2):
	texture.position = snap_to_grid(pos, texture.get_size())

func x_correction():
	texture.position.x = max(texture.position.x, texture.get_size().x / 2)
	texture.position.x = min(texture.position.x, boardSize.x - texture.get_size().x / 2)

func gravity_tick():
	return
	texture.position.y += squareSize.y

func move_left():
	texture.position.x -= squareSize.x
	x_correction()

func move_right():
	texture.position.x += squareSize.x
	x_correction()

func rotate_clockwise():
	texture.advance_frame()
	place_tet(texture.position)
	x_correction()

func rotate_counter_clockwise():
	texture.rewind_frame()
	place_tet(texture.position)
	x_correction()
