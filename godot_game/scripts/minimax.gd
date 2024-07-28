extends Control

var start_size: Vector2

var debug
@export var scale_factor: float
var start_scale

func _ready():
	debug = find_parent('DebugContent')
	await get_tree().process_frame

func _on_min_down():
	debug.clippy_area.minimise()

func _on_normalise_down():
	debug.clippy_area.normalise()
	
func _on_max_down():
	debug.clippy_area.maximise()
