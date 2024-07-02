extends Node2D

@onready var baseTet = preload("res://tetris/BaseTetromino.tscn")

@onready var gravityTicker = find_child("GravityTicker")
var currentTet = null;

# Called when the node enters the scene tree for the first time.
func _ready():
	currentTet = baseTet.instantiate()
	currentTet.width = 3;
	currentTet.height = 2;
	currentTet.map = "100,111"
	add_child(currentTet)
	
	gravityTicker.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_gravity_ticker_timeout():
	currentTet.gravity_tick()
