extends Control

var start_size: Vector2
var window
var debug
@export var scale_factor: float
var start_scale

func _ready():
	window = find_parent('Game').get_parent()
	debug = find_parent('DebugContent')
	start_size = window.size
	await get_tree().process_frame
	start_scale = debug.creature.scale
	
func _on_min_down():
	minimise()

func _on_normalise_down():
	normalise()
	
func _on_max_down():
	maximise()
	
func minimise():
	
	if debug.drag_area.clippy:
		debug.creature.scale = start_scale / scale_factor
	else:
		window.size = start_size / scale_factor

func normalise():
	if debug.clippy:
		debug.creature.scale = start_scale
	else:
		window.size = start_size

func maximise():
	if debug.drag_area.clippy:
		debug.creature.scale = start_scale * scale_factor
	else:
		window.size = start_size * scale_factor

func _on_normal_button_button_down():
	window.size = start_size
