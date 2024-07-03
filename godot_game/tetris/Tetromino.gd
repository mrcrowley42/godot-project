extends Node2D

@onready var canvas = find_child("CanvasLayer")
@onready var texture = find_child("Texture")
var boardSize: Vector2
var squareSize: Vector2 = Vector2(30, 30)

func snap_to_grid(vec: Vector2, size: Vector2) -> Vector2:
	var sMod = Vector2(
			int(size.x) % int(squareSize.x * 2), 
			int(size.y) % int(squareSize.y * 2)
		)
	return vec - (squareSize / 2) * sMod.normalized()

func init(piece: String, bPos: Vector2, bSize: Vector2):
	boardSize = bSize
	canvas.offset = bPos
	texture.animation = piece

func place_tet(pos: Vector2):
	texture.position = snap_to_grid(pos, texture.get_size())

func gravity_tick():
	print("fall")
