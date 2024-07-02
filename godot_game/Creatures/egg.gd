extends Node2D
@onready var cracker = %eggTimer

func timerset():
	%eggTimer.wait_time = 2
	%eggTimer.one_shot = true
	%eggTimer.autostart = true



func _ready():
	timerset()
	cracker.timeout.connect(func():
		print("done"))



func _process(delta):
	pass
