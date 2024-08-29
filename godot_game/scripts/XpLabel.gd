extends Label

@onready var start_text = text


func _process(_delta):
	text = start_text % [get_parent().creature.xp]
