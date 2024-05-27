extends Timer

func _ready():
	self.timeout.connect(call_tick)

func call_tick():
	print('aw')
