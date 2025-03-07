extends Button

@onready var egg_scene = load("res://scenes/UiScenes/egg_info.tscn")
var egg: EggEntry

func setup(the_egg: EggEntry):
	egg = the_egg
	icon = Helpers.crop_img(egg.image)
	text = "\n" + egg.name


func _on_button_down() -> void:
	var parent = find_parent("CreaturesMenu")
	var scene = egg_scene.instantiate()
	scene.egg = egg
	scene.setup()
	parent.add_child(scene)
