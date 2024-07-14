extends Node2D

@onready var cracker = %EggTimer
@export var skip_scene: bool
func _enter_tree():
	
	%LilGuy.visible = false
	%EggSprite.visible = true

func _ready():
	# This is not a good way to do this, but I'm sick of clicking skip -_-
	if skip_scene:
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/GameScenes/prototype.tscn")
	
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
