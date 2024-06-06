extends Node2D

# initializes a new creature's stats object for game mechanic purposes 
var Autismo = Stats.new()


# function to set all creaturs stats on load that can be quickly changed
func SetCeatures():
	Autismo.SetStats(100, 100, 100, 5)
	
	

# Called when the node enters the scene tree for the first time.  
func _ready():
	
	SetCeatures()

	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
