extends Control

@onready var creature: Creature = %Creature
@onready var ui = %UI_Theme_Manager
@onready var stat_man = %StatusManager
@onready var music_track = %MainMusic
@onready var minigame_man: MinigameManager = %MinigameManager
@onready var clippy_area: Button  = %ClippyArea
@onready var background = %Background
@onready var screen_tint = %BG
@onready var notif_man = %NotificationManager
@onready var cosmetic_btns = %CosmeticItems
@onready var game = self.find_parent("Game")

var example_messages = ["random", "word", "banana", "mario", "bingus"]

func _on_h_slider_value_changed(value) -> void:
	stat_man.time_multiplier = value


func _on_button_button_down() -> void:
	creature.reset_stats()


func _ready() -> void:
	var anims = creature.find_child('Main').sprite_frames.get_animation_names()
	for anim in anims:
		$AnimSelect.add_item(anim)
	$AnimSelect.selected = 3
	$ColorPickerButton.color = creature.dying_colour
	stat_man.finished_loading.connect(update_holiday)
	$CheckBox.visible = game.unlock_fps
	$CheckBox.button_pressed = game.unlock_fps


func update_holiday() -> void:
	if stat_man.holiday_mode:
		$HolidayBtn.set_pressed_no_signal(true)


func _process(_delta) -> void:
	$Strength.text =  '%.2f' % [stat_man.time_multiplier]
	var fps = Engine.get_frames_per_second()
	$Label3.text = str(fps)
	if fps < 49.0:
		$Label3.set("theme_override_colors/font_color", Color.LIGHT_CORAL)
	elif fps < 59.0:
		$Label3.set("theme_override_colors/font_color", Color.LIGHT_GOLDENROD)
	else:
		$Label3.set("theme_override_colors/font_color", Color.LIGHT_GREEN)


func _on_anim_select_item_selected(index) -> void:
	creature.find_child('Main').animation = $AnimSelect.get_item_text(index)


func _on_overlay_strength_value_changed(value) -> void:
	screen_tint.material.set("shader_parameter/tint_strength", value)


func _on_color_picker_button_popup_closed() -> void:
	creature.dying_colour = $ColorPickerButton.color


func _on_button_3_toggled(toggled_on) -> void:
	stat_man.holiday_mode = toggled_on
	print(stat_man.holiday_mode)


func _on_clippy_btn_pressed() -> void:
	clippy_area.toggle_clippy_mode()


func _on_h_slider_2_value_changed(value) -> void:
	clippy_area.clippy_opacity = value
	if clippy_area.clippy:
		creature.find_child("Sprites").self_modulate = Color(1,1,1,clippy_area.clippy_opacity)


func _on_check_box_toggled(toggled_on) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


func _on_notif_btn_button_down() -> void:
	var msg = example_messages.pick_random()
	notif_man.new_notification(msg)


func _on_wipe_btn_button_down() -> void:
	var d = DirAccess.open("res://")
	d.remove(Globals.SAVE_DATA_FILE)
	get_tree().quit()


func _on_wipe_nodes_btn_button_down() -> void:
	var d = DirAccess.open("res://")
	d.remove(Globals.SAVE_DATA_FILE)
	DataGlobals.save_only_metadata()
	get_tree().quit()


func _on_unlock_button_button_down() -> void:
	# this is kinda horrendous ngl but I just wanted it to work 
	var uid_dict: Dictionary = {}
	var unlocked_items = DataGlobals.load_metadata()['unlocked_items']
	for item: CosmeticItem in load("res://resources/unlockables.tres").unlockables:
		var uid = str(ResourceLoader.get_resource_uid(item.resource_path))
		if item.unlocked:
			unlocked_items.append(uid)
		uid_dict[uid] = item
	var unlockables = load("res://resources/unlockables.tres").unlockables

	var item_list = []
	for item in unlockables:
		item_list.append(str(ResourceLoader.get_resource_uid(item.resource_path)))
	DataGlobals.metadata_to_add[DataGlobals.UNLOCKED_ITEMS] = item_list
	DataGlobals.save_only_metadata()
	cosmetic_btns.update_buttons()
	for item in DataGlobals.load_metadata()['unlocked_items']:
		if item not in unlocked_items:
			var cosmetic = uid_dict[item]
			var message = "%s Unlocked!" %[cosmetic.name]
			notif_man.new_notification(message)
