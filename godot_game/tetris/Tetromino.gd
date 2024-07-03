extends Node2D

@onready var canvas = find_child("CanvasLayer")
@onready var texture = find_child("Texture")

var boardSize: Vector2
var squareSize: Vector2 = Vector2(30, 30)
var resting = false

## snap given vec to grid of squareSize
func snap_to_grid(vec: Vector2):
	var topLeft = vec - texture.get_size() / 2
	var amount = Vector2(
			int(topLeft.x) % int(squareSize.x), 
			int(topLeft.y) % int(squareSize.y)
		)
	texture.position = vec - amount

func init(piece: String, bPos: Vector2, bSize: Vector2):
	boardSize = bSize
	canvas.offset = bPos
	texture.set_anim(piece)

## performs wall-kick based on normal given for tetmomino
func x_correction(direction=0):
	var offset_pos = texture.get_clipped_pos()
	var cSize_x = texture.get_clipped_size().x / 2
	var cSize_x_r = boardSize.x - cSize_x
	var isClipped = texture.get_size().x / 2 != cSize_x
	
	if cSize_x > offset_pos.x:
		texture.position.x = texture.position.x + squareSize.x if isClipped else cSize_x
	elif cSize_x_r < offset_pos.x:
		texture.position.x = texture.position.x - squareSize.x if isClipped else cSize_x_r

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
