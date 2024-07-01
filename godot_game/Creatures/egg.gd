extends Node2D

#var to set wait time until egg hatches 
@export var wait_time: float 

var Hatching = Timer


func _ready():
	
	Hatching.start
	
func _process(delta):
	pass
