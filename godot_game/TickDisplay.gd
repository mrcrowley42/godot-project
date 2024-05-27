extends SpinBox


func _on_ticker_tick():
	var v = self.value + 1
	self.value = v if v <= self.max_value else 0  # reset value if too high
