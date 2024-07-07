extends Node2D

@onready var base_tet = preload("res://tetris/Tetromino.tscn")
@onready var gravity_ticker = %GravityTicker
@onready var quick_drop_ticker = find_child("QuickDropTicker")
@onready var grid_bg = find_child("GridBG")
@onready var hold_box = find_child("HoldBox")
@onready var next_box = find_child("NextBox")

const INPUTS_LEFT = [KEY_A, KEY_LEFT]
const INPUTS_RIGHT = [KEY_D, KEY_RIGHT]

const BOARD_SIZE: Vector2 = Vector2(300, 600)
const ALLOWED_PIECES = ['l_a', 'l_b', 'long', 'skew_a', 'skew_b', 'square', 't']

# GAME STATES
var all_pieces = []
var tet_queue = []
var active_tet = null
var held_tet = null
var can_hold = true
var is_quick_dropping = false

func get_next_tet() -> String:
	if len(tet_queue) < 4:
		generate_tet_queue()
	return tet_queue.pop_front()

## add 2 * each piece to the end of the queue shuffled randomly (fisher-yates shuffle)
func generate_tet_queue():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var pieces = ALLOWED_PIECES + ALLOWED_PIECES
	pieces.sort()
	for i in len(pieces):
		var j = rng.randi_range(i, len(pieces) - 1)
		var i_piece = pieces[i]
		pieces[i] = pieces[j]
		pieces[j] = i_piece
	tet_queue.append_array(pieces)

func activate_tet(tetromino):
	active_tet = tetromino
	active_tet.snap_to_grid(Vector2(BOARD_SIZE.x / 2, -active_tet.body.get_size().y / 2))  # middle top, just off screen
	active_tet.update_ghost()
	active_tet.connect("placed", active_tet_placed)

func activate_new_tet(piece):
	var new_tet = base_tet.instantiate()
	add_child(new_tet)
	new_tet.init(piece, grid_bg.position, BOARD_SIZE, all_pieces)
	activate_tet(new_tet)

## hold active tet and spawn currently held piece or new piece
func hold_active_tet():
	if can_hold:
		var swapped_tet = held_tet
		held_tet = active_tet
		active_tet.disconnect("placed", active_tet_placed)
		if swapped_tet == null:
			activate_new_tet(get_next_tet())
		else:
			swapped_tet.stop_holding_tet()
			activate_tet(swapped_tet)
		var pos = hold_box.position - (hold_box.size * hold_box.scale) / 2
		held_tet.holding_tet(pos)
		can_hold = false

func _ready():
	all_pieces.append(find_child("Ground"))
	activate_new_tet(get_next_tet())
	generate_tet_queue()
	gravity_ticker.start()
	quick_drop_ticker.start()

func _input(event):
	# press once
	if event.is_action_pressed("tetris_rotate_clockwise"):
		active_tet.rotate_clockwise()
	if event.is_action_pressed("tetris_rotate_counter_clockwise"):
		active_tet.rotate_counter_clockwise()
	if event.is_action_pressed("tetris_quick_drop"):
		is_quick_dropping = true
	if event.is_action_released("tetris_quick_drop"):
		is_quick_dropping = false
	if event.is_action_pressed("tetris_instant_drop"):
		active_tet.drop_to_ghost()
	if event.is_action_pressed("tetris_hold"):
		hold_active_tet()
	
	# hold-able
	if (event is InputEventKey) and event.pressed:
		if event.keycode in INPUTS_LEFT:
			active_tet.move_left()
		if event.keycode in INPUTS_RIGHT:
			active_tet.move_right()

func _on_gravity_ticker_timeout():
	if !is_quick_dropping:
		active_tet.gravity_tick()

func _on_quick_drop_timer_timeout():
	if is_quick_dropping:
		active_tet.gravity_tick()

## triggered when the active tetromino is placed
func active_tet_placed():
	all_pieces.append(active_tet)
	activate_new_tet(get_next_tet())
	can_hold = true
