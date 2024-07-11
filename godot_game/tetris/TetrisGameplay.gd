extends Node2D

class_name TetrisGameplay

@onready var base_tet = preload("res://tetris/Tetromino.tscn")
@onready var top_overlay: CanvasLayer = find_child("TopOverlay")
@onready var gravity_ticker: Timer = find_child("GravityTicker")
@onready var quick_drop_ticker: Timer = find_child("QuickDropTicker")
@onready var drop_particle: CPUParticles2D = find_child("DropParticle")
@onready var break_particle: CPUParticles2D = find_child("BreakParticle")
@onready var grid_bg = find_child("GridBG")
@onready var hold_box = find_child("HoldBox")
@onready var next_box = find_child("NextBox")

const INPUTS_LEFT = [KEY_A, KEY_LEFT]
const INPUTS_RIGHT = [KEY_D, KEY_RIGHT]

const BOARD_SIZE: Vector2 = Vector2(300, 600)
const ALLOWED_PIECES = ['l_a', 'l_b', 'long', 'skew_a', 'skew_b', 'square', 't']

# GAME STATES
var running = true
var score = 0
var all_pieces = []
var tet_queue = []
var active_tet: Tetromino = null  # Tetromino
var held_tet: Tetromino = null
var can_hold = true
var is_quick_dropping = false

# UI QUEUE (non initialised pieces)
var queued_1: Tetromino;  # save to free them later 
var queued_2: Tetromino;

func get_next_piece() -> String:
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
	var new_tet: Tetromino = base_tet.instantiate()
	add_child(new_tet)
	new_tet.init(piece, grid_bg.position, BOARD_SIZE, all_pieces)
	activate_tet(new_tet)
	new_tet.remove_piece.connect(remove_tet)

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

## instant drop & spawns particles
func instant_drop():
	var colour = active_tet.body.get_colour()
	var size: Vector2 = active_tet.body.get_clipped_size()
	var pos_before: Vector2 = active_tet.body.get_clipped_pos(false)
	var pos_after: Vector2 = active_tet.drop_to_ghost()
	
	var addition = 0
	while pos_after.y > pos_before.y + addition:
		var perc = (pos_before.y + addition) / pos_after.y
		var lifetime = 0.3 + perc
		spawn_particle(pos_before + Vector2(-size.x / 2, addition), colour, true, lifetime)
		spawn_particle(pos_before + Vector2(size.x / 2, addition), colour, true, lifetime)
		addition += 15

func _ready():
	all_pieces.append(find_child("Ground"))
	activate_new_tet(get_next_piece())
	generate_tet_queue()
	update_ui_queue()
	gravity_ticker.start()
	quick_drop_ticker.start()

func _input(event):
	if running:
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
			instant_drop()
		if event.is_action_pressed("tetris_hold"):
			hold_active_tet()
		
		# hold-able
		if (event is InputEventKey) and event.pressed:
			if event.keycode in INPUTS_LEFT:
				active_tet.move_left()
			if event.keycode in INPUTS_RIGHT:
				active_tet.move_right()

func _on_gravity_ticker_timeout():
	if running and !is_quick_dropping:
		active_tet.gravity_tick()

func _on_quick_drop_timer_timeout():
	if running and is_quick_dropping:
		active_tet.gravity_tick()

## triggered when the active tetromino is placed
func active_tet_placed():
	all_pieces.append(active_tet)
	activate_new_tet(get_next_piece())
	check_for_completed_lines()  # after activating a new tet
	check_for_game_over()  # after completing lines
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

func check_for_game_over():
	for tet in all_pieces:
		if is_instance_of(tet, Tetromino):
			for point: Vector2 in tet.body.get_raw_collision_points():
				if point.y - 30 <= grid_bg.position.y:
					running = false
					print("FAILURE")
					return

## accesses the raw coll2d children of each tet body's collision area
func move_all_pieces_down(above_y, places: int):
	for tet in all_pieces:
		if is_instance_of(tet, Tetromino):
			# i gave up and just retrieved the children, too many small differences otherwise
			for node: CollisionShape2D in tet.body.collision_area.get_children():
				if !node.disabled and Vector2(tet.body.base_pos + tet.body.relative_pos + node.position).y < above_y:
					node.position.y += 30 * places

## checks through every placed node pos and finds any new completed lines (excludes currently completing lines)
func check_for_completed_lines():
	var completed_lines: Array[CompletedLine] = []
	var lines_dict = {}  # saves the y pos (key) of nodes (Array value)
	
	for tet in all_pieces:
		if is_instance_of(tet, Tetromino):
			for point: Vector2 in tet.body.get_raw_collision_points():
				if point.y not in lines_dict:
					lines_dict[point.y] = []
				lines_dict[point.y].append(tet.body.get_coll_node_from_raw_position(point))
	
	var sorted_keys = lines_dict.keys()
	sorted_keys.sort()  # from top (lowest y pos) down
	for y_pos in sorted_keys:
		var nodes_array: Array = lines_dict[y_pos]
		if len(nodes_array) >= 10:  # full line
			# if directly below a CompletedLine that has just been created, add a line to it, 
			# otherwise create a new CompletedLine
			var added = false
			for cl: CompletedLine in completed_lines:
				if y_pos == cl.highest_y + (30 * cl.lines_completed):
					cl.lines_completed += 1
					cl.add_nodes(nodes_array)
					added = true
			if !added:
				completed_lines.append(CompletedLine.new(self, nodes_array, y_pos))
	
	for line: CompletedLine in completed_lines:
		line.complete()

class CompletedLine:
	var parent_node: TetrisGameplay
	var nodes: Array = []  # nodes encompassed in the line/s
	var lines_completed: int = 1
	var highest_y
	
	func _init(parent: Node2D, initial_nodes: Array, y_pos):
		parent_node = parent
		add_nodes(initial_nodes)
		highest_y = y_pos  # the pos given in constructor will always be the highest
	
	func add_nodes(nodes_list: Array):
		nodes += nodes_list
	
	func complete():
		for node: CollisionShape2D in nodes:
			var body: TetBody = node.get_parent().get_parent()  # ew but whatever
			parent_node.spawn_particle(body.position + node.position, body.get_colour())
			node.disabled = true
			node.visible = false
			node.queue_free()  # outright deletion >:)
		parent_node.move_all_pieces_down(highest_y, lines_completed)
		parent_node.active_tet.update_ghost()

func spawn_particle(pos: Vector2, colour: Color, drop=false, lifetime=null):
	var part: CPUParticles2D = drop_particle.duplicate() if drop else break_particle.duplicate()
	top_overlay.add_child(part)
	part.connect("finished", remove_node.bind(part))
	
	if lifetime != null:
		part.lifetime = lifetime
	part.modulate = colour / 255
	part.modulate.a = 1  # reset the alpha
	part.position = pos
	part.emitting = true

## called when a placed tet body finds it has no more collision points enabled
func remove_tet(tet: Tetromino):
	all_pieces.erase(tet)
	remove_node(tet)

## general function to delete a node
func remove_node(node):
	node.queue_free()
