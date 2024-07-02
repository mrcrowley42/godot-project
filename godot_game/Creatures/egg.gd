extends Node2D
@onready var cracker = %eggTimer
@export var set_wait: float

func party_time():
	pass

func scene_set():
	%lilGuy.visible = false
	%eggSprite.visible = true
	cracker.wait_time = set_wait

func _ready():
	scene_set()
	
	cracker.timeout.connect(func():
		print("done")
		%Yip.play()
		%eggSprite.visible = false
		%lilGuy.visible = true
		)



func _process(delta):
	pass
