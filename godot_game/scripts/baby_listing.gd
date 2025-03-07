extends Button

@onready var baby_scene = load("res://scenes/UiScenes/baby_info.tscn")
var baby: CreatureBaby

func setup(the_baby: CreatureBaby):
	baby = the_baby
	var uid = Helpers.uid_str(baby)
	var babies = DataGlobals.get_global_metadata_value(DataGlobals.DISCOVERED_BABIES)
	
	if uid in babies.keys():
		disabled = false
		icon = Helpers.crop_img(baby.baby_part.sprite_frames.get_frame_texture('idle', 0))
		text = "\n" + baby.name
	else:
		disabled = true


func _on_button_down() -> void:
	var parent = find_parent("CreaturesMenu")
	var scene = baby_scene.instantiate()
	scene.baby = baby
	scene.setup()
	parent.add_child(scene)
