extends Node2D

@onready var baseTet = preload("res://tetris/Tetromino.tscn")
@onready var gravityTicker = find_child("GravityTicker")
@onready var gridBG = find_child("GridBG")

var boardSize: Vector2 = Vector2(300, 600)
var currentTet = null

func add_tet(piece):
	currentTet = baseTet.instantiate()
	add_child(currentTet)
	currentTet.init(piece, gridBG.position, boardSize)
	currentTet.place_tet(Vector2(boardSize.x / 2, -15))

func _ready():
	add_tet("long")
	gravityTicker.start()

func _on_gravity_ticker_timeout():
	currentTet.gravity_tick()
