extends Node2D

@onready var base_tet = preload("res://tetris/Tetromino.tscn")
@onready var gravity_ticker = %gravity_ticker
@onready var grid_bg = find_child("GridBG")

var inputs_left = [KEY_A, KEY_LEFT]
var inputs_right = [KEY_D, KEY_RIGHT]

var board_size: Vector2 = Vector2(300, 600)
var all_pieces = []
var active_tet = null

func get_random_tet() -> String:
	return ['l_a', 'l_b', 'long', 'skew_a', 'skew_b', 'square', 't'].pick_random()

func activate_new_tet(piece):
	active_tet = base_tet.instantiate()
	add_child(active_tet)
	active_tet.init(piece, grid_bg.position, board_size, all_pieces)
	active_tet.snap_to_grid(Vector2(board_size.x / 2, -active_tet.body.get_size().y / 2))  # middle top, just off screen
	active_tet.connect("placed", active_tet_placed)

func _ready():
	all_pieces.append(find_child("Ground"))
	activate_new_tet("long")
	gravity_ticker.start()

func _input(event):
	# press once
	if event.is_action_pressed("rotate_clockwise"):
		active_tet.rotate_clockwise()
	if event.is_action_pressed("rotate_counter_clockwise"):
		active_tet.rotate_counter_clockwise()
	# hold-able
	if (event is InputEventKey) and event.pressed:
		if event.keycode in inputs_left:
			active_tet.move_left()
		if event.keycode in inputs_right:
			active_tet.move_right()

func _on_gravity_ticker_timeout():
	active_tet.gravity_tick()

## triggered when the active tetromino is placed
func active_tet_placed():
	all_pieces.append(active_tet)
	activate_new_tet("long")
