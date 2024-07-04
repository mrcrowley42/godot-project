extends Node2D
@onready var cracker = %eggTimer
@export var set_wait: float


func _enter_tree():
	%lilGuy.visible = false
	%eggSprite.visible = true
	%eggTimer.wait_time = set_wait

func _ready():
	cracker.timeout.connect(func():
		print("done")
		%crack.play()
		%Yip.play()
		%eggSprite.visible = false
		%lilGuy.visible = true
		%Confetti.confet()
		%startGame.start()
		)
	
	%startGame.timeout.connect(func():
		print("done")
		get_tree().change_scene_to_file("res://scenes/prototype.tscn")
		)

