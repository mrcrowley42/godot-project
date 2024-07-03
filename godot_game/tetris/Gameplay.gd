extends Node2D

@onready var baseTet = preload("res://tetris/Tetromino.tscn")
@onready var gravityTicker = find_child("GravityTicker")
@onready var gridBG = find_child("GridBG")

var controllsLeft = [KEY_A, KEY_LEFT]
var controllsRight = [KEY_D, KEY_RIGHT]

var boardSize: Vector2 = Vector2(300, 600)
var activeTet = null

func add_tet(piece):
	activeTet = baseTet.instantiate()
	add_child(activeTet)
	activeTet.init(piece, gridBG.position, boardSize)
	activeTet.place_tet(Vector2(boardSize.x / 2, -activeTet.texture.get_size().y / 2))  # middle top, just off screen

func _ready():
	add_tet("t")
	gravityTicker.start()

func _on_gravity_ticker_timeout():
	activeTet.gravity_tick()

# capture input
func _input(event):
	if (event is InputEventKey) and event.pressed:
		if event.keycode in controllsLeft:
			activeTet.move_left()
		if event.keycode in controllsRight:
			activeTet.move_right()
