extends Node

# there has to be a better way to do this...
@onready var stat_man: StatusManager = $"..".get_parent().get_parent().find_child("StatusManager")
@onready var creature: Creature = $"..".get_parent().get_parent().find_child("Creature")

var og_state: String

func _ready():
	og_state = creature.find_child('AnimatedSprite2D').animation
	creature.find_child('AnimatedSprite2D').animation = "chill"
	stat_man.time_multiplier = -1.0
	
func _exit_tree():
	# Return animation state to what is was before entering the scene.
	creature.find_child('AnimatedSprite2D').animation = og_state
