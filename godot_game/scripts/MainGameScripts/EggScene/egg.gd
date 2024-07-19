extends Node2D


@onready var cracker: Timer = %EggTimer
@export var skip_scene: bool


func _enter_tree() -> void:
	%LilGuy.visible = false
	%EggSprite.visible = true

func _ready():
	cracker.timeout.connect(func():
		print("done")
		%Yip.play()
		%EggSprite.visible=false
		%LilGuy.visible=true
		%Confetti.confet()
		%StartGame.start()
		)
	
	%StartGame.timeout.connect(func():
		print("done")
		get_tree().change_scene_to_file("res://scenes/GameScenes/prototype.tscn")
		)

func CreatureSelector():
	pass
	

