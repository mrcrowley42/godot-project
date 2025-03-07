extends Button

@onready var baby_scene = load("res://scenes/UiScenes/baby_info.tscn")
var baby: CreatureBaby

func setup(the_baby: CreatureBaby):
	baby = the_baby
	icon = Helpers.crop_img(baby.baby_part.sprite_frames.get_frame_texture('idle', 0))
	text = "\n" + baby.name


func _on_button_down() -> void:
	var parent = find_parent("CreaturesMenu")
	var scene = baby_scene.instantiate()
	scene.baby = baby
	scene.setup()
	parent.add_child(scene)
