extends AnimatedSprite2D
@onready var creature = $".."

func _ready():
	creature.sp_changed.connect(angry)
	creature.hp_changed.connect(stop_it)

func angry():
	if creature.sp < 600:
		self.animation = 'confused'
	else:
		if self.animation != 'idle':
			self.animation = 'idle'

func stop_it():
	if creature.hp < 300:
		%STAHP.play()
