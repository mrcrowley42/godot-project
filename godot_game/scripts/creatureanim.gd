extends AnimatedSprite2D
@onready var creature = $".."

@onready var confetti_l = $"../../ConfettiParticleL"
@onready var confetti_r = $"../../ConfettiParticleR"

func _ready():
	#creature.sp_changed.connect(angry)
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

func _input(event):
	# hide container if mouse clicks outside of its rect
	if (event is InputEventMouseButton) and event.pressed:
		var size = self.sprite_frames.get_frame_texture(animation, frame).get_size() * scale
		var pos = get_parent().position - (size / 2)
		if Rect2(pos, size).has_point(event.position):
			if !confetti_l.emitting and !confetti_r.emitting:
				confetti_l.restart();
				confetti_r.restart();
				confetti_l.emitting = true;
				confetti_r.emitting = true;
