class_name Game extends Node

@export var debug_mode: bool
@export var unlock_fps: bool = false

var last_saved: float
@onready var launch_time: float = Time.get_unix_time_from_system()
@onready var stat_man: StatusManager = %StatusManager
@onready var minigame_man: MinigameManager = %MinigameManager
@onready var debug_window = $DebugWindow

@onready var ui_overlay: Sprite2D = find_child("UI_Overlay")
@onready var trans_img: Sprite2D = find_child("Transition")

var is_in_transition: bool = false;

func _ready():
	if debug_mode:
		print_rich("[color=%s]--- RUNNING IN DEBUG MODE! ---" % Color.AQUA.to_html())
	
	if unlock_fps:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	# if no data exists, file has been tampered with, set the bare minimum
	# metadata is set automatically after egg opening scene, and before this scene
	if !DataGlobals.has_save_data():
		DataGlobals.save_only_metadata()

	# load in data
	var metadata = DataGlobals.load_data()
	last_saved = metadata[DataGlobals.LAST_SAVED] if metadata.has(DataGlobals.LAST_SAVED) else launch_time
	DataGlobals.load_settings_data()
	calc_elapsed_time()

	# Disable the script execution when the panel is disabled/hidden.
	debug_window.visible = debug_mode
	if not debug_mode:
		debug_window.process_mode = Node.PROCESS_MODE_DISABLED
	
	# force this function to run since load() isn't called
	if DataGlobals.has_only_metadata():
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

## temp print to console
func calc_elapsed_time():
	var elapsed_time = launch_time - last_saved
	# please excuse the bad variable names here, this is only a temp thing anyway.
	if debug_mode:
		var _a = Color(1,0,0)
		var _b = Color(0,1,0)
		var max_time = 600  # in seconds
		var _c = _b.lerp(_a, clampf(elapsed_time/max_time,0,1))
		_c.v = 1.0
		_c = _c.lightened(.25)
		print_rich("[color=%s]%.2f seconds since last played.[/color]" %[_c.to_html() ,elapsed_time])
		print("%.2f days since last played." %[elapsed_time/86400])
		var holiday_status = "were" if stat_man.holiday_mode else "were not"
		print("And you %s on holiday." % [holiday_status])


## finilise & save data before closure
func _notification(noti):
	# close game
	if noti == NOTIFICATION_WM_CLOSE_REQUEST:
		minigame_man.finalise_save_data()  # call before saving
		DataGlobals.save_data()
		DataGlobals.save_settings_data()
	
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
