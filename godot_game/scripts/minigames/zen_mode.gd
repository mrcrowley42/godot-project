extends MiniGameLogic

# there has to be a better way to do this...
@onready var stat_man: StatusManager = $"..".get_parent().get_parent().find_child("StatusManager")
@onready var creature: Creature = $"..".get_parent().get_parent().find_child("Creature")

var og_state: String

func _ready():
	creature.zen = true
	
	stat_man.time_multiplier = 0.25
	new_timer(stat_man.fun_rate, add_fun)

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
