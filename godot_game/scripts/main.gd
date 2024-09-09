extends Node

@export var debug_mode: bool
@export var unlock_fps: bool = false

var last_saved: float
@onready var launch_time: float = Time.get_unix_time_from_system()
@onready var stat_man: StatusManager = %StatusManager
#@onready var launch_date = Time.get_datetime_dict_from_system().day
@onready var minigame_man: MinigameManager = %MinigameManager
@onready var debug_window = $DebugWindow

var is_in_transition: bool = false;

func _ready():
	if unlock_fps:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED) # HUH?

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

	# do last
	perform_opening_transition()

func set_is_in_trans(value: bool):
	is_in_transition = value

func perform_opening_transition():
	var ui_overlay: Sprite2D = find_child("UI_Overlay")
	var trans_img: Sprite2D = find_child("Transition")
	trans_img.rotation = 0
	trans_img.position = ui_overlay.position
	get_tree().create_tween().tween_property(trans_img, "position", trans_img.position + Vector2(0, 1000), 1.5)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(.3).connect("finished", set_is_in_trans.bind(false))

func perform_closing_transition(func_to_call):
	if !is_in_transition:
		set_is_in_trans(true)
		var ui_overlay: Sprite2D = find_child("UI_Overlay")
		var trans_img: Sprite2D = find_child("Transition")
		trans_img.rotation = PI
		trans_img.position.y = -1000
		get_tree().create_tween().tween_property(trans_img,
			"position",
			ui_overlay.position,
			1.
		).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(.5).timeout
		func_to_call.call()

## temp print to console
func calc_elapsed_time():
	var elapsed_time = launch_time - last_saved
	# please excuse the bad variable names here, this is only a temp thing anyway.
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


func _on_save_pressed():
	%BtnClick.play()
	%SFX.play_sound("correct")
	DataGlobals.save_settings_data()

## finilise & save data before closure
func _notification(noti):
	if noti == NOTIFICATION_WM_CLOSE_REQUEST:
		minigame_man.finalise_save_data()  # call before saving
		DataGlobals.save_data()

	if noti == Globals.NOFITICATION_GROW_TO_ADULT_SCENE:
		var p = func(): print("done")
		await perform_closing_transition(p)
		var creature: Creature = find_child("Creature")
		creature.life_stage = Creature.LifeStage.ADULT if creature.life_stage != 1 else 0
		creature.update_sprite()
		perform_opening_transition()


func _input(event) -> void:
	# close when [param esc key] is pressed
	if event.is_action_pressed("ui_cancel"):
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()
