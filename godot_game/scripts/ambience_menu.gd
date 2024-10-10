extends VBoxContainer

@onready var category_btn: OptionButton = find_child("CategoryBtn")
@onready var sound_btn = find_child("SoundBtn")
var categories = load("res://resources/ambience_categories.tres").items

func _ready() -> void:
	# remove placeholder text	
	category_btn.remove_item(0)
	for category in categories:
		category_btn.add_icon_item(category.image, category.category_name)
	category_btn.item_selected.emit(0)

func update_sound_list(category):
	sound_btn.clear()
	for sound in category.sound_resources:
		sound_btn.add_item(sound.sound_name)
	sound_btn.select(0)

func _on_category_btn_item_selected(index: int) -> void:
	update_sound_list(categories[index])
