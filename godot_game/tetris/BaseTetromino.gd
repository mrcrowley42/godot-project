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


func place_tet():
	pos = Vector2(5 - floor(width / 2), 0)


func _ready():
	check_map_integrity()
	place_tet()


func gravity_tick():
	print("fall")
