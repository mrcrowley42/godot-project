extends MarginContainer

@export var heading: Node
@export var preview: Node
@onready var btn_sfx = find_parent("Game").find_child("BtnClick")
@onready var showcase_scene = load("res://scenes/UiScenes/creature_showcase.tscn")
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
	preview.sprite_frames = creature.baby.sprite_frames
	preview.autoplay = "idle"


func _on_button_button_down() -> void:
	var showcase = showcase_scene.instantiate()
	showcase.creature = creature
	add_child(showcase)
