extends Node2D

@onready var baseTet = preload("res://tetris/BaseTetromino.tscn")

@onready var gravityTicker = find_child("GravityTicker")

var boardWidth = 10;
var boardHeight = 20;
var currentTet = null;

func add_tet(w, h, map):
	currentTet = baseTet.instantiate()
	currentTet.width = w;
	currentTet.height = h;
	currentTet.map = map;
	currentTet.init(boardWidth, boardHeight)
	add_child(currentTet)

func _ready():
	add_tet(3, 2, "100,111")
	gravityTicker.start()

func _on_gravity_ticker_timeout():
	currentTet.gravity_tick()
