class_name MainSprite extends AnimatedSprite2D

@onready var creature = find_parent("Creature")

enum Movement {NOTHING, HAPPY_BOUNCE, CONFUSED_SHAKE}

var amount_dict = {Movement.HAPPY_BOUNCE: 40, Movement.CONFUSED_SHAKE: 20}

var current_movement: Movement = Movement.NOTHING
var movement_queue: Movement = Movement.NOTHING
var movement_start: float = 0

const MOVEMENT_TIME: float = 1;


func angry():
	if creature.food < 600:
		self.animation = 'confused'
	else:
		if self.animation != 'idle':
			self.animation = 'idle'


## changes the animation and retains frame change timing
func change_animation(anim_name: String) -> bool:
	if not sprite_frames.has_animation(anim_name):
		printerr("current creature has no animation: " + anim_name)
		return false
	
	if anim_name == animation:
		return true
	
	await frame_changed
	animation = anim_name
	return true


func do_movement(movement: Movement):
	if current_movement != Movement.NOTHING:
		movement_queue = movement
		return
	
	if movement == Movement.HAPPY_BOUNCE and not await change_animation("joy"):
		await change_animation("chill")
	if movement == Movement.CONFUSED_SHAKE:
		await change_animation("confused")
	
	current_movement = movement
	movement_start = Time.get_unix_time_from_system()

func end_movement():
	position = Vector2(0, 0)
	current_movement = Movement.NOTHING
	if movement_queue != Movement.NOTHING:
		do_movement(movement_queue)
	else:
		change_animation("idle")
	movement_queue = Movement.NOTHING

func _process(_delta: float) -> void:
	if current_movement != Movement.NOTHING:
		var t = Time.get_unix_time_from_system() - movement_start
		
		if t >= MOVEMENT_TIME:
			end_movement()
			return
		
		var inv_percent = 1-(t / MOVEMENT_TIME)
		if current_movement == Movement.HAPPY_BOUNCE:
			position.y = (-abs(sin(t * 8)) * amount_dict[current_movement]) * inv_percent
		
		if current_movement == Movement.CONFUSED_SHAKE:
			position.x = (sin(t * 14) * amount_dict[current_movement]) * inv_percent
