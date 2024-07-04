extends Node2D

@onready var baseTet = preload("res://tetris/Tetromino.tscn")
@onready var gravityTicker = find_child("GravityTicker")
@onready var gridBG = find_child("GridBG")

var inputsLeft = [KEY_A, KEY_LEFT]
var inputsRight = [KEY_D, KEY_RIGHT]

var boardSize: Vector2 = Vector2(300, 600)
var activeTet = null

func add_tet(piece):
	activeTet = baseTet.instantiate()
	add_child(activeTet)
	activeTet.init(piece, gridBG.position, boardSize)
	activeTet.snap_to_grid(Vector2(boardSize.x / 2, -activeTet.texture.get_size().y / 2))  # middle top, just off screen

func _ready():
	add_tet("skew_a")
	gravityTicker.start()

func _on_gravity_ticker_timeout():
	activeTet.gravity_tick()

func _input(event):
	# press once
	if event.is_action_pressed("rotate_clockwise"):
		activeTet.rotate_clockwise()
	if event.is_action_pressed("rotate_counter_clockwise"):
		activeTet.rotate_counter_clockwise()
	# hold-able
	if (event is InputEventKey) and event.pressed:
		if event.keycode in inputsLeft:
			activeTet.move_left()
		if event.keycode in inputsRight:
			activeTet.move_right()
