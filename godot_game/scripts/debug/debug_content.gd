extends Control

@onready var creature: Creature = %Creature
@onready var ui = %UI_Theme_Manager
@onready var stat_man = %StatusManager
@onready var minigame_man: MinigameManager = %MinigameManager
@onready var clippy_area: Button  = %ClippyArea
@onready var background = %Background
@onready var screen_tint = %BG
@onready var notif_man: NotificationManager = %NotificationManager
@onready var cosmetic_btns = %CosmeticItems
@onready var theme_btns = %ThemeBtns
@onready var facts_menu = %FactsMenu
@onready var game = self.find_parent("Game")
@onready var ambience_man = game.find_child("AmbienceManager")


var example_messages = ["random", "word", "banana", "mario", "bingus"]
var example_icons = [
	preload("res://images/ambience/campfire.png"),
	preload("res://images/ambience/forest.png"),
	preload("res://images/ambience/ocean.png"),
	preload("res://images/ambience/ambience_electrical.png")
]

func _on_h_slider_value_changed(value) -> void:
	stat_man.time_multiplier = value


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
	creature.change_animation($AnimSelect.get_item_text(index))


func _on_overlay_strength_value_changed(value) -> void:
	screen_tint.material.set("shader_parameter/tint_strength", value)


func _on_color_picker_button_popup_closed() -> void:
	creature.dying_colour = $ColorPickerButton.color


func _on_button_3_toggled(_toggled_on) -> void:
	stat_man.toggle_holiday_mode()
	print(stat_man.holiday_mode)


func _on_clippy_btn_pressed() -> void:
	clippy_area.toggle_clippy_mode()


func _on_h_slider_2_value_changed(value) -> void:
	clippy_area.clippy_opacity = value
	if clippy_area.clippy:
		creature.find_child("Sprites").self_modulate = Color(1,1,1,clippy_area.clippy_opacity)


func _on_check_box_toggled(toggled_on) -> void:
	var vsync = DisplayServer.VSYNC_DISABLED if toggled_on else DisplayServer.VSYNC_ENABLED
	DisplayServer.window_set_vsync_mode(vsync)


func _on_notif_btn_button_down() -> void:
	var msg = example_messages.pick_random()
	notif_man.new_basic_notification(msg)


func _on_notif_btn_2_button_down() -> void:
	var msg = example_messages.pick_random()
	var icon = example_icons.pick_random()
	notif_man.new_adv_notification(msg, icon)


func _on_wipe_btn_button_down() -> void:
	var d = DirAccess.open("res://")
	d.remove(Globals.SAVE_DATA_FILE)
	get_tree().quit()


func _on_wipe_nodes_btn_button_down() -> void:
	var metadata = DataGlobals.get_global_metadata_dc()
	metadata[DataGlobals.CURRENT_CREATURE] = "-1"
	metadata[DataGlobals.ID_INCREMENTAL] = "0"
	
	var d = DirAccess.open("res://")
	d.remove(Globals.SAVE_DATA_FILE)
	DataGlobals.save_only_global_metadata(metadata)
	get_tree().quit()


func _on_unlock_button_button_down() -> void:
	# UNLOCK ALL COSMETICS
	_on_unlock_cosmetics_button_down()

	# UNLOCK ALL FACTS
	_on_unlock_facts_button_down()

	# UNLOCK ALL THEMES
	_on_unlock_themes_button_down()
	
	# ACHIEVEMENTS
	_on_unlock_achs_button_down()

	## dont re-render here, let the game handle it
	# Rerender unlockable item buttons
	#cosmetic_btns.update_buttons()
	#theme_btns.update_buttons()
	#facts_menu.propagate_call("update_locked")


func _on_button_3_button_down() -> void:
	ambience_man.current_sounds()


func _on_button_2_button_down() -> void:
	creature.add_xp(10_000)

func _on_button_4_button_down() -> void:
	creature.create_save_icon()


func _on_unlock_facts_button_down() -> void:
	for fact in load("res://resources/fact_list.tres").facts:
		Globals.unlock_fact(fact)


func _on_unlock_achs_button_down() -> void:
	for achievement in load("res://resources/all_achievements.tres").items:
		Globals.unlock_achievement(achievement)


func _on_unlock_themes_button_down() -> void:
	for ui_theme in load("res://resources/ui_theme_list.tres").theme_list:
		Globals.unlock_theme(ui_theme)


func _on_unlock_cosmetics_button_down() -> void:
	for cosmetic in load("res://resources/unlockables.tres").unlockables:
		Globals.unlock_cosmetic(cosmetic)


func _on_full_restore_button_down() -> void:
	creature.reset_stats()

func _on_hp_restore_button_down() -> void:
	creature.reset_stat(creature.Stat.HP)

func _on_fun_restore_button_down() -> void:
	creature.reset_stat(creature.Stat.FUN)

func _on_water_restore_button_down() -> void:
	creature.reset_stat(creature.Stat.WATER)

func _on_food_restore_button_down() -> void:
	creature.reset_stat(creature.Stat.FOOD)


func _on_discover_all_btn_button_down() -> void:
	_on_discover_babies_btn_button_down()
	_on_discover_creatures_btn_button_down()


func _on_discover_babies_btn_button_down() -> void:
	var discovered = DataGlobals.get_global_metadata_value(DataGlobals.DISCOVERED_BABIES)
	for baby: CreatureBaby in load("res://resources/baby_list.tres").items:
		var uid = Helpers.uid_str(baby)
		if uid not in discovered.keys():
			DataGlobals.add_to_babies_discovered(baby)


func _on_discover_creatures_btn_button_down() -> void:
	var discovered = DataGlobals.get_global_metadata_value(DataGlobals.DISCOVERED_BABIES)
	for creature: CreatureType in load("res://resources/creature_list.tres").items:
		var uid = Helpers.uid_str(creature)
		if uid not in discovered.keys():
			DataGlobals.add_to_creatures_discovered(creature)
		DataGlobals.set_new_highest_life_stage(uid, Creature.LifeStage.ADULT)
