extends MarginContainer

@export var heading: Node
@export var description: Node

@onready var btn_sfx = find_parent("Game").find_child("BtnClick")

var creature: CreatureType


func _on_back_button_down() -> void:
	btn_sfx.play()
	queue_free()


func _on_hidden() -> void:
	queue_free()


func setup():
	if not creature:
		return
		
	heading.text = "%s" % creature.name
	description.text = "%s" % creature.desc
		
