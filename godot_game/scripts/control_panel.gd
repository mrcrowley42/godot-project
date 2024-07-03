
extends PanelContainer
@onready var creature = %Creature

var just_closed = false

func _ready():
	visible = false

func _process(_delta):
	just_closed = false

func _input(event):
	# hide container if mouse clicks outside of its rect
	if self.visible and (event is InputEventMouseButton) and event.pressed:
		var container_rect = Rect2(self.position, self.size)
		if !container_rect.has_point(event.position):
			just_closed = true
			self.hide()

func _on_button_1_button_down():
	creature.dmg(-300, 'sp')


func _on_button_3_button_down():
	creature.dmg(-300, 'hp')


func _on_visibility_changed():
	if just_closed and visible:
		self.hide()
