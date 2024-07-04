extends Node2D
@onready var cracker = %EggTimer



func _enter_tree():
	%LilGuy.visible = false
	%EggSprite.visible = true
	

func _ready():
	cracker.timeout.connect(func():
		print("done")
		%Crack.play()
		%Yip.play()
		%EggSprite.visible = false
		%LilGuy.visible = true
		%Confetti.confet()
		%StartGame.start()
		)
	
	%StartGame.timeout.connect(func():
		print("done")
		get_tree().change_scene_to_file("res://scenes/prototype.tscn")
		)

