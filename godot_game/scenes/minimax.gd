extends Control

var start_size
var window

func _ready():
	window = find_parent('Game').get_parent()
	start_size = window.size
	
func _on_min_down():
	minimise()
	
func _on_max_down():
	maximise()
	
func minimise():
	window.size.x = start_size.x / 2
	window.size.y = start_size.y / 2
	#get_tree().change_scene_to_file("res://scenes/vol_slider.tscn")
	
func maximise():
	window.size.x = start_size.x
	window.size.y = start_size.y
