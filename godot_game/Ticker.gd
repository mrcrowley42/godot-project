extends SpinBox

var timer = Timer.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	timer.one_shot = false
	timer.process_callback = Timer.TIMER_PROCESS_IDLE
	timer.wait_time = 1
	add_child(timer)
	
	# signal to be called
	timer.start()
	timer.connect("timeout", _tick)


func _tick():
	self.value += 1
