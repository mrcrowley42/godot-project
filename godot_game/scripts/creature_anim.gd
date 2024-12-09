extends AnimatedSprite2D

@onready var creature = find_parent("Creature")


func angry():
	if creature.food < 600:
		self.animation = 'confused'
	else:
		if self.animation != 'idle':
			self.animation = 'idle'


func do_happy_bounce(amnt = 10):
	pass

func do_confused_shake(amnt = 10):
	pass
