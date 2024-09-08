extends AnimatedSprite2D

@onready var creature = find_parent("Creature")

func _ready():
	#creature.food_changed.connect(angry)
	creature.hp_changed.connect(stop_it)

func angry():
	if creature.food< 600:
		self.animation = 'confused'
	else:
		if self.animation != 'idle':
			self.animation = 'idle'

func stop_it():
	if creature.hp < 30:
		%STAHP.play_random()


func _on_animation_changed():
	pass
	#if animation == 'angry':
		#%NotificationBubble.show()
	#else:
		#%NotificationBubble.hide()

