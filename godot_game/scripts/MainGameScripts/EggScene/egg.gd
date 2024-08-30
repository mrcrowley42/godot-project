extends Node2D

## sets variables when scene is loaded 
@onready var cracker: Timer = %EggTimer
@onready var creature: AnimatedSprite2D = creature_selector()
@export var skip_scene: bool

func _enter_tree() -> void:

	%EggSprite.visible = true

func _ready() -> void:
	# This is not a good way to do this, but I'm sick of clicking skip -_-
	if skip_scene:
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/GameScenes/main.tscn")
	
	## process for when the egg timer ends, "pirnts()" are for process checking 
	cracker.timeout.connect(func() -> void:
		print(creature)
		print("done")
		%Yip.play()
		%EggSprite.visible= false
		creature.visible= true
		%Confetti.confet()
		%StartGame.start()
		)
	
	## process for after start game timer ends, timer is for slight delay to give time for users to process 
	%StartGame.timeout.connect(func() -> void:
		print("done")
		get_tree().change_scene_to_file("res://scenes/GameScenes/main.tscn")
		)

## function for selecting which character to use, can be used as condition for creature class construction
func creature_selector():
	var array = [
		%LilGuy,
		%Flopps
	]
	
	for x in array:
		x.visible = false
		
	return array.pick_random()



func _on_lil_guy_visibility_changed():
	pass # Replace with function body.
