class_name MainMenu extends ScriptNode

@export var auto_continue: bool

@onready var egg_scene = preload("res://scenes/GameScenes/egg_opening.tscn")
var egg_scene_instance: EggOpening = null

@onready var load_menu = find_child("LoadMenu")
@onready var settings_menu = find_child("SettingsMenu")
@onready var bg_gradient: TextureRect = find_child("BgGradient")
@onready var trans_img: Sprite2D = find_child("Transition")
@onready var new_game_btn: Button = find_child("NewGameBtn")
@onready var load_creature_btn: Button = find_child("LoadBtn")
@onready var btn_sfx = find_child("BtnClick")
@onready var continue_btn: Button = find_child("ContinueBtn")
@onready var wipe_menu = find_child("ConfirmWipeMenu")
@onready var hatch_egg_btn: Button = find_child("HatchEggBtn")

@onready var egg_openning_layer: CanvasLayer = find_child("EggOpenningLayer")

var center_pos
var is_in_transition = true

func _ready() -> void:
	DataGlobals.load_settings_data()
	
	var user_cfg = DataGlobals.settings_data_last_loaded
	if user_cfg.has('general'):
		auto_continue = user_cfg['general'].get('skip_intro', false)

	if auto_continue and Globals.first_launch:
		Globals.change_to_scene("res://scenes/GameScenes/main.tscn")
		return
	DataGlobals.load_data()
	
	Globals.send_notification(Globals.NOTIFICATION_ALL_DATA_IS_LOADED)
	center_pos = bg_gradient.size / 2
	
	setup_btn_visibility()
	do_opening_trans()
	[%Music1, %Music2, %Music3].pick_random().play()


func setup_btn_visibility():
	new_game_btn.visible = DataGlobals.has_only_global_metadata() or not DataGlobals.has_save_data()
	continue_btn.visible = !new_game_btn.visible
	load_creature_btn.visible = !new_game_btn.visible
	hatch_egg_btn.visible = len(DataGlobals.get_global_metadata_value(DataGlobals.PENDING_EGGS)) > 0


func grab_saves():
	var creature_save_ids = DataGlobals.get_all_creature_ids()
	var saves = []
	for save_id in creature_save_ids:
		var save_info = {}
		save_info['id'] = save_id
		save_info['last_saved'] = DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_LAST_SAVED, save_id)
		save_info['creature_name'] = DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_NAME, save_id)
		save_info['status'] = DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_INITIAL_LIFE_STAGE, save_id)
		saves.append(save_info)
	return saves


func do_opening_trans():
	Globals.perform_opening_transition(trans_img, center_pos, set_is_in_trans.bind(false))


func do_closing_trans():
	set_is_in_trans(true)
	return await Globals.perform_closing_transition(trans_img, center_pos)


func set_is_in_trans(value: bool):
	is_in_transition = value


func _on_quit_btn_button_down() -> void:
	if not is_in_transition:
		print("closing game from main menu...")
		get_tree().quit()


func _on_continue_btn_button_down() -> void:
	btn_sfx.play()
	if not is_in_transition:
		fade_out_music()
		await do_closing_trans()
		Globals.change_to_scene("res://scenes/GameScenes/main.tscn")


func _on_new_game_btn_button_down() -> void:
	btn_sfx.play()
	if not is_in_transition:
		await do_closing_trans()
		egg_scene_instance = egg_scene.instantiate()
		egg_openning_layer.add_child(egg_scene_instance)
		egg_scene_instance.back_to_main_menu.connect(exit_egg_scene_to_main_menu)
		egg_scene_instance.do_closing_trans.connect(go_to_main_game)
		do_opening_trans()


func go_to_main_game():
	fade_out_music()
	await do_closing_trans()
	Globals.change_to_scene("res://scenes/GameScenes/main.tscn")


func exit_egg_scene_to_main_menu():
	await do_closing_trans()
	egg_scene_instance.back_to_main_menu.disconnect(exit_egg_scene_to_main_menu)
	egg_scene_instance.do_closing_trans.disconnect(go_to_main_game)
	egg_scene_instance.queue_free()
	do_opening_trans()


func _on_load_btn_button_down() -> void:
	btn_sfx.play()
	if not is_in_transition:
		load_menu.show()


func _on_load_save_btn_button_down() -> void:
	btn_sfx.play()
	if load_menu.current_save_id != null:
		DataGlobals.set_metadata_value(true, DataGlobals.CURRENT_CREATURE, load_menu.current_save_id)
		_on_continue_btn_button_down.call_deferred()

func fade_out_music():
	Globals.tween(%Music1, "volume_db", -100, 0., 1., Tween.EaseType.EASE_IN_OUT)
	Globals.tween(%Music2, "volume_db", -100, 0., 1., Tween.EaseType.EASE_IN_OUT)


func _on_settings_btn_button_down() -> void:
	btn_sfx.play()
	settings_menu.show()


func _on_confirm_wipe_button_down() -> void:
	# keep metadata
	var metadata = DataGlobals.get_global_metadata_dc()
	metadata[DataGlobals.CURRENT_CREATURE] = "-1"
	metadata[DataGlobals.ID_INCREMENTAL] = "0"
	metadata[DataGlobals.PENDING_EGGS] = []
	
	var d = DirAccess.open(Globals.SAVE_LOCATION_PREFIX + "://")
	d.remove(Globals.SAVE_DATA_FILE)
	DataGlobals.save_only_global_metadata(metadata)
	get_tree().quit()
	
	# icons
	for filename: String in d.get_files():
		if filename.begins_with("save_icon_"):
			d.remove(filename)
	get_tree().quit()


func _on_cancel_wipe_button_down() -> void:
	wipe_menu.hide()


func _on_wipe_save_btn_button_down() -> void:
	wipe_menu.show()


# beautiful
func _on_music_1_finished():
	[%Music2, %Music3].pick_random().play()

func _on_music_2_finished():
	[%Music1, %Music3].pick_random().play()

func _on_music_3_finished():
	[%Music1, %Music2].pick_random().play()
