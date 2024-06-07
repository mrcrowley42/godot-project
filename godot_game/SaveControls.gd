extends PanelContainer


func _input(event):
	# hide container if mouse clicks outside of its rect
	if self.visible and (event is InputEventMouseButton) and event.pressed:
		var container_rect = Rect2(self.position, self.size)
		if !container_rect.has_point(event.position):
			self.hide()
