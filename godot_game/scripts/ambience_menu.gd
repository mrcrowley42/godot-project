extends VBoxContainer

@onready var category_btn: OptionButton = find_child("CategoryBtn")
@onready var sound_btn = find_child("SoundBtn")

func _ready() -> void:
	# remove placeholder text
	category_btn.remove_item(0)
	sound_btn.remove_item(0)
	
	# just loading fire here for testing
	var fire = load("res://resources/ambient_sounds/categories/category_fire.tres")
	category_btn.add_icon_item(fire.image, fire.category_name)
	for sound in fire.sound_resources:
		sound_btn.add_item(sound.sound_name)
