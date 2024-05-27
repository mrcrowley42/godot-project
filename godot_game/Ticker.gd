extends Timer

signal tick

func _ready():
	self.timeout.connect(call_tick)

func call_tick():
	tick.emit()
