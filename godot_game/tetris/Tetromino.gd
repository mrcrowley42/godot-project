extends Node2D

@onready var canvas = find_child("CanvasLayer")
@onready var texture = find_child("Texture")
var boardSize: Vector2

func snap_to_grid(vec: Vector2, size: Vector2) -> Vector2:
	vec = floor(vec) - (size / 2)  # get top left of given thing
	var mod = Vector2(int(vec.x) % 30, int(vec.y) % 30)
	return vec - (mod * 2)

func init(piece: String, bPos: Vector2, bSize: Vector2):
	boardSize = bSize
	canvas.offset = bPos
	texture.animation = piece
	
	place_tet()

func place_tet():
	texture.position = snap_to_grid(texture.position, texture.get_size())

func gravity_tick():
	print("fall")
