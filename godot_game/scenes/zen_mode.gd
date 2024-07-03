extends Node
# there has to be a better way...
@onready var stat_man: StatusManager = $"..".get_parent().get_parent().find_child("StatusManager")

#var orginal_scale: float

func _ready():
	stat_man.time_multiplier = -1.0
