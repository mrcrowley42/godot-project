extends Node2D

@onready var baseTet = preload("res://tetris/Tetromino.tscn")
@onready var gravityTicker = find_child("GravityTicker")
@onready var gridBG = find_child("GridBG")

var boardSize: Vector2 = Vector2(10, 20)
var currentTet = null

func add_tet(piece):
	currentTet = baseTet.instantiate()
	add_child(currentTet)
	currentTet.init(piece, gridBG.position, boardSize)

func _ready():
	add_tet("t")
	gravityTicker.start()

func _on_gravity_ticker_timeout():
	currentTet.gravity_tick()
