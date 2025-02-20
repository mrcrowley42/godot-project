extends VBoxContainer

@onready var category_btn: OptionButton = find_child("CategoryBtn")
@onready var sound_list_container = find_child("SoundListBox")
@onready var sound_btn = find_child("SoundBtn")
@onready var count_label: Label = find_child("SoundCountLabel")

@export var ambience_man: AmbienceManager
@export var ach_man: AchievementManager

@export var amb_sounds_ach: Achievement

var current_category: AmbientSoundCategory
var current_sound
var count_label_tween: Tween

var categories = load("res://resources/ambience_categories.tres").items
const AMBIENCE_CONTROL = preload("res://scenes/UiScenes/ambience_control.tscn")

func _ready() -> void:
	# remove placeholder text
	category_btn.remove_item(0)
	for category in categories:
		category_btn.add_icon_item(category.image, category.category_name)
	category_btn.item_selected.emit(0)
	
	update_count_label(0)


func update_sound_list(category) -> void:
	sound_btn.clear()
	for sound in category.sound_resources:
		sound_btn.add_item(sound.sound_name)
	sound_btn.item_selected.emit(0)


func _on_category_btn_item_selected(index: int) -> void:
	if %AmbienceMenu.visible:
		%BtnClick.play()
	current_category = categories[index]
	update_sound_list(current_category)


func _on_add_sound_btn_button_down() -> void:
	# too many!
	if ambience_man.get_sound_count() >= Globals.MAX_AMBIENT_SOUNDS:
		if count_label_tween != null and count_label_tween.is_running():
			count_label_tween.stop()
		count_label.modulate = Color.RED
		count_label_tween = Globals.tween(count_label, "modulate", Color.WHITE, 0, 1., Tween.EASE_OUT)
		Globals.unlock_achievement(amb_sounds_ach)
		return
	
	# add sound
	ambience_man.add_sound_node(current_category, current_sound)
	if %AmbienceMenu.visible:
		%BtnClick.play()
	var sound_control = AMBIENCE_CONTROL.instantiate()
	sound_control.sound_node = ambience_man.get_child(-1)
	sound_list_container.add_child(sound_control)
	
	DataGlobals.save_settings_data()
	update_count_label()
	ach_man.customise_everything_counter(ach_man.CUSTOMISATIONS.AMBIENCE)


func _on_sound_btn_item_selected(index: int) -> void:
	if %AmbienceMenu.visible:
		%BtnClick.play()
	current_sound = current_category.sound_resources[index]

func update_control_list():
	for sound in ambience_man.current_sounds():
		var sound_control = AMBIENCE_CONTROL.instantiate()
		sound_control.sound_node = sound
		sound_list_container.add_child(sound_control)

func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_AMBIENT_SOUNDS_REMOVED:
		if %AmbienceMenu.visible:
			%BtnClick.play()
		update_count_label(1)  # because queue_free() takes a while, manually subtract 1

func update_count_label(sub: int = 0):
	count_label.text = "%s/%s sounds" % [ambience_man.get_sound_count()-sub, Globals.MAX_AMBIENT_SOUNDS]


func _on_ambience_menu_visibility_changed():
	if ambience_man.has_loaded:
		if %AmbienceMenu.visible:
			update_control_list()
			update_count_label()
