extends Node2D
 
func cracking():
	var hatching: Timer = Timer.new()
	add_child(hatching)
	hatching.autostart = true
	hatching.wait_time = 2.0
	hatching.one_shot = true
	hatching.timeout.connect(timeout())
	
func timeout():
	print("Its alive")
