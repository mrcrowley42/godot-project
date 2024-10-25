extends VBoxContainer

@onready var category_btn: OptionButton = find_child("CategoryBtn")
@onready var sound_list_container = find_child("SoundListBox")
@onready var sound_btn = find_child("SoundBtn")
var categories = load("res://resources/ambience_categories.tres").items
@export var ambience_man: Node
var current_category
var current_sound

func _ready() -> void:
	# remove placeholder text	
	category_btn.remove_item(0)
	for category in categories:
		category_btn.add_icon_item(category.image, category.category_name)
	category_btn.item_selected.emit(0)


func update_sound_list(category) -> void:
	sound_btn.clear()
	for sound in category.sound_resources:
		sound_btn.add_item(sound.sound_name)
	sound_btn.item_selected.emit(0)


func _on_category_btn_item_selected(index: int) -> void:
	current_category = categories[index]
	update_sound_list(current_category)
	update_control_list()


func _on_add_sound_btn_button_down() -> void:
	ambience_man.add_sound_node(current_sound)
	%BtnClick.play()
	DataGlobals.save_settings_data()


func _on_sound_btn_item_selected(index: int) -> void:
	current_sound = current_category.sound_resources[index]
	
func update_control_list():
	for sound in ambience_man.current_sounds():
		print(sound)
