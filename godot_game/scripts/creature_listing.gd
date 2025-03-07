extends Button

@onready var child_scene = load("res://scenes/UiScenes/creature_info.tscn")
var creature: CreatureType

func setup(the_creature: CreatureType):
	creature = the_creature
	icon = Helpers.crop_img(creature.child.sprite_frames.get_frame_texture('idle', 0))
	text = "\n" + creature.name


func _on_button_down() -> void:
	var parent = find_parent("CreaturesMenu")
	var scene = child_scene.instantiate()
	scene.creature = creature
	scene.setup()
	parent.add_child(scene)
