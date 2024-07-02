extends Node2D

#var to set wait time until egg hatches 
@export var wait_time: float 


	
func egg_timer():
	var hatching = Timer.new()
	hatching.wait_time = wait_time
	hatching.autostart = true
	hatching.one_shot = true
	add_child(%Timer)

	
func _ready():
	egg_timer()
	
func _process(delta):
	pass


