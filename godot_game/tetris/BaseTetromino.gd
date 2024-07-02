extends Node2D

@onready var canvas = find_child("CanvasLayer")
@onready var texture = find_child("Texture")
var boardSize: Vector2

func round_down_to_grid(vec: Vector2):
	vec = floor(vec)  # no decimals allowed >:)
	return vec - Vector2(int(vec.x) % 30, int(vec.y) % 30)

func init(piece: String, bPos: Vector2, bSize: Vector2):
	boardSize = bSize
	canvas.offset = bPos
	texture.animation = piece
	
	place_tet()

func place_tet():
	pass

func gravity_tick():
	print("fall")
