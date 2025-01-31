class_name MainMenu extends ScriptNode

@export var auto_continue: bool

@onready var load_menu = find_child("LoadMenu")
@onready var bg_gradient: TextureRect = find_child("BgGradient")
@onready var trans_img: Sprite2D = find_child("Transition")
@onready var new_game_btn = find_child("NewGameBtn")
var center_pos
var is_in_transition = true

func _ready() -> void:
	if auto_continue:
		Globals.change_to_scene("res://scenes/GameScenes/main.tscn")
		return
	
	DataGlobals.load_data()
	Globals.send_notification(Globals.NOTIFICATION_ALL_DATA_IS_LOADED)
	center_pos = bg_gradient.size / 2
	# if save file
	#new_game_btn.hide()
	do_opening_trans()


func grab_saves():
	var creature_save_ids = DataGlobals.get_all_creature_ids()
	var saves = []
	for save_id in creature_save_ids:
		var save_info = {}
		save_info['last_played'] = DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_LAST_SAVED, save_id)
		save_info['creature_name'] = DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_NAME, save_id)
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
	if not is_in_transition:
		fade_out_music()
		await do_closing_trans()
		Globals.change_to_scene("res://scenes/GameScenes/main.tscn")


func _on_new_game_btn_button_down() -> void:
	if not is_in_transition:
		fade_out_music()
		await do_closing_trans()
		Globals.change_to_scene("res://scenes/GameScenes/egg_opening.tscn")


func _on_load_btn_button_down() -> void:
	if not is_in_transition:
		load_menu.show()


func _on_load_save_btn_button_down() -> void:
	# TODO LOAD CURRENTLY SELECTED GAME FILE AND MARK IT AS THE CURRENT ONE.
	pass # Replace with function body.

func fade_out_music():
	var t = Globals.tween(%Music, "volume_db", -100, 0., 1., Tween.EaseType.EASE_IN_OUT)

func load():
	# ADD THE AUTO CONTINUE LOAD SETTING HERE, AND ADD IT TO GENERAL?
	pass
