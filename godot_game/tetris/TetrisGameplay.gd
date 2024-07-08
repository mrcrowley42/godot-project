extends Node2D

@onready var base_tet = preload("res://tetris/Tetromino.tscn")
@onready var gravity_ticker = find_child("GravityTicker")
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
var active_tet: Tetromino = null  # Tetromino
var held_tet: Tetromino = null
var can_hold = true
var is_quick_dropping = false
var completing_lines: Array[int] = []  # lines that have been receognised as completed and are currently mid-animation

# UI QUEUE (non initialised pieces)
var queued_1: Tetromino;  # save to free them later 
var queued_2: Tetromino;

func get_next_piece() -> String:
	return "l_a"
	if len(tet_queue) < 4:
		generate_tet_queue()
	var piece = tet_queue.pop_front()
	update_ui_queue()
	return piece

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
			activate_new_tet(get_next_piece())
		else:
			swapped_tet.stop_holding_tet()
			activate_tet(swapped_tet)
		var pos = hold_box.position - (hold_box.size * hold_box.scale) / 2
		held_tet.holding_tet(pos)
		can_hold = false

func _ready():
	all_pieces.append(find_child("Ground"))
	activate_new_tet(get_next_piece())
	generate_tet_queue()
	update_ui_queue()
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
	
	var completed_lines = check_for_completed_lines()
	
	activate_new_tet(get_next_piece())
	can_hold = true

func update_ui_queue():
	if queued_1 != null and queued_2 != null:
		queued_1.queue_free()
		queued_2.queue_free()
	
	queued_1 = base_tet.instantiate()
	queued_2 = base_tet.instantiate()
	add_child(queued_1)
	add_child(queued_2)
	
	queued_1.body.set_anim(tet_queue[0])
	queued_2.body.set_anim(tet_queue[1])
	var next_box_size = next_box.size * next_box.scale
	var quater_size = Vector2(0, next_box_size.y / 4)
	var next_box_middle = next_box.position - next_box_size / 2
	queued_1.set_raw_position(next_box_middle - quater_size)
	queued_2.set_raw_position(next_box_middle + quater_size)
	queued_1.body.scale = queued_1.SMALL_SCALE
	queued_2.body.scale = queued_2.SMALL_SCALE

## checks through every placed node pos and finds any new completed lines (excludes currently completing lines)
func check_for_completed_lines():
	var newly_completed_lines: Array[CompletedLine] = []
	var lines_dict = {}  # saves the y pos (key) of nodes (Array value)
	
	for tet in all_pieces:
		if is_instance_of(tet, Tetromino):
			for point: Vector2 in tet.body.get_raw_collision_points():
				if point.y not in lines_dict:
					lines_dict[point.y] = []
				lines_dict[point.y].append(tet.body.get_coll_node_from_raw_position(point))
	
	var sorted_keys = lines_dict.keys()
	sorted_keys.sort()
	for y_pos in sorted_keys:  # from bottom up
		var nodes_array: Array = lines_dict[y_pos]
		print(y_pos, " ", len(nodes_array))
		if y_pos not in completing_lines and len(nodes_array) >= 10:  # full line
			completing_lines.append(y_pos)
			
			# if directly above a CompletedLine that has just been created, add a line to it, 
			# otherwise create a new CompletedLine
			var added = false
			for cl: CompletedLine in newly_completed_lines:
				if y_pos == cl.lowest_line_y + (30 * cl.lines_completed):
					cl.lines_completed += 1
					cl.add_nodes(nodes_array)
					added = true
			if !added:
				newly_completed_lines.append(CompletedLine.new(self, nodes_array))
	print(newly_completed_lines)

class CompletedLine:
	var timer: Timer = Timer.new()
	var timout_counter: int = 0
	var nodes: Array = []  # nodes encompassed
	var lines_completed: int = 1
	var lowest_line_y
	
	func _init(parent: Node2D, initial_nodes: Array):
		timer.wait_time = 0.5
		timer.autostart = true
		timer.connect("timeout", on_timeout)
		add_nodes(initial_nodes)
		parent.add_child(timer)
	
	func add_nodes(nodes_list: Array):
		nodes += nodes_list
	
	func complete():
		timer.disconnect("timrout", on_timeout)
		timer.queue_free()
		for node in nodes:
			node.queue_free()  # outright deletion >:)
	
	func on_timeout():
		timout_counter += 1
		if timout_counter > 6:
			complete()
