extends Node2D


@onready var cracker: Timer = %EggTimer
@export var skip_scene: bool


func _enter_tree() -> void:

	%LilGuy.visible = false
	%EggSprite.visible = true

func _ready() -> void:
	# This is not a good way to do this, but I'm sick of clicking skip -_-
	if skip_scene:
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/GameScenes/main.tscn")
	
	cracker.timeout.connect(func() -> void:
		print("done")
		%Yip.play()
		%EggSprite.visible=false
		%LilGuy.visible=true
		%Confetti.confet()
		%StartGame.start()
		)
	
	%StartGame.timeout.connect(func() -> void:
		print("done")
		get_tree().change_scene_to_file("res://scenes/GameScenes/main.tscn")
		)

func CreatureSelector():
	pass
	

