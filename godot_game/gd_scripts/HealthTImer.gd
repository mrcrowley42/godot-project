extends Timer

@export var ticks_per_second: float

signal tick

func _ready():
	self.wait_time = 1/ticks_per_second
	self.timeout.connect(call_tick)

func call_tick():
	tick.emit()
