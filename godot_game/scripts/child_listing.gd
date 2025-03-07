extends Button

@onready var child_scene = load("res://scenes/UiScenes/child_info.tscn")
var child: CreatureType

func setup(the_child: CreatureType):
	child = the_child
	icon = Helpers.crop_img(child.child.sprite_frames.get_frame_texture('idle', 0))
	text = "\n" + child.name


func _on_button_down() -> void:
	var parent = find_parent("CreaturesMenu")
	var scene = child_scene.instantiate()
	scene.child = child
	scene.setup()
	parent.add_child(scene)
