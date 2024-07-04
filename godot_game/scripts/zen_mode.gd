extends Node
# there has to be a better way...
@onready var stat_man: StatusManager = $"..".get_parent().get_parent().find_child("StatusManager")
# there has to be a better way...
@onready var creature: Creature = $"..".get_parent().get_parent().find_child("Creature")
#var orginal_scale: float
var og_state

func _ready():
	og_state = creature.find_child('AnimatedSprite2D').animation
	creature.find_child('AnimatedSprite2D').animation = "chill"
	stat_man.time_multiplier = -1.0
	
func _exit_tree():
	creature.find_child('AnimatedSprite2D').animation = og_state
