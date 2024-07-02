extends Node2D

@export var width: int
@export var height: int
@export var map: String;

var resting = false;
var pos: Vector2;


func check_map_integrity():
	var map_split = map.split(",")
	var map_length = map.replace(",", "").length()
	
	for ih in height:
		assert(map_split[ih].length() == width)
	assert(width * height == map_length)

func place_tet(boardWidth):
	pos = Vector2((boardWidth / 2.0) - floor(width / 2.0), 0)

func init(boardWidth, _boardHeight):
	check_map_integrity()
	place_tet(boardWidth)

func gravity_tick():
	print("fall")
