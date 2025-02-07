class_name ActionMenu extends PanelContainer

var just_closed: bool = false

func _ready():
	visible = false

func _process(_delta):
	just_closed = false

func _input(event):
	# hide container if mouse clicks outside of its rect
	if self.visible and (event is InputEventMouseButton) and event.pressed:
		var container_rect = Rect2(self.position, find_child("Container").size)
		if !container_rect.has_point(event.position):
			just_closed = true
			self.hide()


func _on_visibility_changed():
	if just_closed and visible:
		self.hide()
