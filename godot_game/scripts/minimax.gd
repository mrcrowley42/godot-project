extends Control

var start_size
var window

func _ready():
	window = find_parent('Game').get_parent()
	start_size = window.size
	
func _on_min_down():
	minimise()

func _on_normalise_down():
	normalise()
	
func _on_max_down():
	maximise()
	
func minimise():
	window.size.x = start_size.x / 2
	window.size.y = start_size.y / 2
	#get_tree().change_scene_to_file("res://scenes/vol_slider.tscn")

func normalise():
	window.size.x = start_size.x * 1
	window.size.y = start_size.y * 1

func maximise():
	window.size.x = start_size.x * 1.33
	window.size.y = start_size.y * 1.33
	

func _on_normal_button_button_down():
	window.size = start_size
