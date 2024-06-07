extends Node2D

# initializes a new creature's stats object for game mechanic purposes 
var Creature_01 = Stats.new()
var Creature_02 = Stats.new()
var Creature_03 = Stats.new()
# function to set all creaturs stats on load that can be quickly changed
func SetCreatures():
	Creature_01.SetStats(100, 100, 100, 5)
	Creature_02.SetStats(100,100,5, 4)
	Creature_03.SetStats(100,100,100, -1)

# Called when the node enters the scene tree for the first time.  
func _ready():
	
	SetCreatures()

	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
