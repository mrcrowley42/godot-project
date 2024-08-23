extends Node2D


@onready var cracker: Timer = %EggTimer
@onready var creature: AnimatedSprite2D = creature_selector()
@export var skip_scene: bool

func _enter_tree() -> void:

	%EggSprite.visible = true

func _ready() -> void:
	# This is not a good way to do this, but I'm sick of clicking skip -_-
	if skip_scene:
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/GameScenes/prototype.tscn")
	
	cracker.timeout.connect(func() -> void:
		print(creature)
		print("done")
		%Yip.play()
		%EggSprite.visible= false
		creature.visible= true
		%Confetti.confet()
		%StartGame.start()
		)
	
	%StartGame.timeout.connect(func() -> void:
		print("done")
		get_tree().change_scene_to_file("res://scenes/GameScenes/prototype.tscn")
		)

func creature_selector():
	var array = [
		%LilGuy,
		%Flopps
	]
	
	for x in array:
		x.visible = false
		
	return array.pick_random()

