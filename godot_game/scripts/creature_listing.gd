extends Button

@onready var child_scene = load("res://scenes/UiScenes/creature_info.tscn")
var creature: CreatureType

func setup(the_creature: CreatureType):
	creature = the_creature
	var uid = Helpers.uid_str(creature)
	var creatures = DataGlobals.get_global_metadata_value(DataGlobals.DISCOVERED_CREATURES)
	
	if uid in creatures:
		disabled = false
		icon = Helpers.crop_img(creature.child.sprite_frames.get_frame_texture('idle', 0))
		text = "\n" + creature.name
	else:
		disabled = true


func _on_button_down() -> void:
	var parent = find_parent("CreaturesMenu")
	var scene = child_scene.instantiate()
	scene.creature = creature
	scene.setup()
	parent.add_child(scene)
