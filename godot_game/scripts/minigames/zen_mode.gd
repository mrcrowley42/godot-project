extends MiniGameLogic

# there has to be a better way to do this...
var stat_man: StatusManager
var creature: Creature

var og_state: String

@export var first_zen_ach: Achievement
@export var many_zen_ach: Achievement

func _ready():
	stat_man = $"..".get_parent().get_parent().get_parent().find_child("StatusManager")
	creature = owner.get_parent().get_parent().get_parent().find_child("Creature")
	creature.zen = true
	
	stat_man.time_multiplier = 0.25
	new_timer(stat_man.fun_rate, add_fun)
	
	Globals.unlock_achievement(first_zen_ach)
	
	# count times openned
	var times_openned: int = 0
	var ach_prog = DataGlobals.get_global_metadata_value(DataGlobals.ACHIEVEMENT_PROGRESS)
	if 'zen_openned' in ach_prog:
		times_openned = int(ach_prog['zen_openned'])
	times_openned += 1
	DataGlobals.modify_metadata_value(true, DataGlobals.ACHIEVEMENT_PROGRESS, ['zen_openned'], DataGlobals.ACTION_SET, str(times_openned))
	
	if times_openned == 10:
		Globals.unlock_achievement(many_zen_ach)

func add_fun():
	creature.add_fun(.5)

func _exit_tree():
	pass
	# Return animation state to what is was before entering the scene.
	
	
func _on_close_btn_button_down():
	creature.zen = false
	#await creature.main_sprite.frame_changed
	close_game()


## Creates a new timer that loops [param rate] times per second,
## and executes the [param timeout_func] at the end of each loop.
func new_timer(rate: float, timeout_func: Callable) -> void:
	var timer = Timer.new()
	timer.wait_time = 1 / rate
	timer.autostart = true
	timer.timeout.connect(timeout_func)
	add_child(timer)
