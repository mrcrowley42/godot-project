extends AnimatedSprite2D
@onready var creature = $".."

func _ready():
	creature.sp_changed.connect(angry)

func angry():
	if creature.sp < 600:
		self.animation = 'confused'
	else:
		if self.animation != 'idle':
			self.animation = 'idle'
