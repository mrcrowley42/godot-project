class_name Game extends Node

@export var debug_mode: bool
@export var unlock_fps: bool = false

@onready var launch_time: float = Time.get_unix_time_from_system()
@onready var stat_man: StatusManager = %StatusManager
@onready var minigame_man: MinigameManager = %MinigameManager
@onready var debug_window = $DebugWindow

@onready var ui_overlay: Sprite2D = find_child("UI_Overlay")
@onready var trans_img: Sprite2D = find_child("Transition")

var is_in_transition: bool = false;

func _ready():
	print("--- RUNNING MAIN.GD IN %s MODE! ---" % "DEBUG" if debug_mode else "NORMAL")
	
	if unlock_fps:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	# if no data exists, file has been tampered with, set the bare minimum
	# metadata is set automatically after egg opening scene, and before this scene
	if !DataGlobals.has_save_data():
		DataGlobals.save_only_metadata()

	## load in all the data
	DataGlobals.load_data()
	DataGlobals.load_creature_data()
	DataGlobals.load_settings_data()
	calc_elapsed_time()

	# Disable the script execution when the panel is disabled/hidden.
	debug_window.visible = debug_mode
	if not debug_mode:
		debug_window.process_mode = Node.PROCESS_MODE_DISABLED
	
	# force this function to run since load() wasn't called
	if DataGlobals.has_only_creature_metadata():
		%Creature.setup_creature()
		%Creature.reset_stats()
	
	Globals.send_notification(Globals.NOTIFICATION_ALL_DATA_IS_LOADED)
	
	# do last
	set_is_in_trans(true)
	do_opening_trans()
	DataGlobals.setup_auto_save(self)

func do_opening_trans():
	Globals.perform_opening_transition(trans_img, ui_overlay.position, set_is_in_trans.bind(false))

func set_is_in_trans(value: bool):
	is_in_transition = value

## debug prints
func calc_elapsed_time():
	var elapsed_time = launch_time - DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_LAST_SAVED)
	if debug_mode:
		var vars = [elapsed_time, elapsed_time/86400, "were" if stat_man.holiday_mode else "were not"]
		print("%.2f seconds (%.2f days) since last played. You %s on holiday" % vars)


## finilise & save data before closure
func _notification(noti):
	# close game
	if noti == NOTIFICATION_WM_CLOSE_REQUEST or noti == Globals.NOTIFICATION_QUIT_TO_MAIN_MENU:
		print("--- Quit notification recieved, attempting safe close of main ---")
		minigame_man.finalise_save_data()  # call before saving
		DataGlobals.save_data()
		DataGlobals.save_settings_data()
		if noti == Globals.NOTIFICATION_QUIT_TO_MAIN_MENU:
			print("exiting to main menu...")
			await Globals.perform_closing_transition(trans_img, ui_overlay.position)
			Globals.change_to_scene("res://scenes/GameScenes/main_menu.tscn")
		else:
			print("exiting...")
		return
	
	# grow up
	if noti == Globals.NOFITICATION_GROW_TO_ADULT_SCENE and not is_in_transition:
		if not is_in_transition:
			set_is_in_trans(true)
			DataGlobals.save_data()  # important!
			Globals.general_dict["current_cosmetics"] = %Creature.get_current_cosmetics()
			Globals.general_dict["loaded_cosmetics"] = %Creature.get_loaded_cosmetics()
			await Globals.perform_closing_transition(trans_img, ui_overlay.position)
			Globals.change_to_scene("res://scenes/GameScenes/grow_up_to_adult.tscn")

func _input(event) -> void:
	# close when [param esc key] is pressed
	if debug_mode and event.is_action_pressed("ui_cancel"):
		Globals.send_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()
	
	## fire confetti
	if debug_mode and (event is InputEventKey) and event.pressed:
		if event.keycode == KEY_Y:
			Globals.fire_confetti(self)
