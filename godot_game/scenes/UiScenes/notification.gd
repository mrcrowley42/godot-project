class_name Notification extends Control

@export_category("Settings")
## Ease type to use for animations.
@export var ease_type: Tween.EaseType = Tween.EASE_OUT_IN
## Transition type to use for animations.
@export var transition_type: Tween.TransitionType = Tween.TRANS_LINEAR
## How long in seconds the transition animation should last.
@export var animation_length: float = 0.5
## How long in seconds after finishing the transition animation should the notification
## remain on screen for.
@export var notification_length: float = 1.0
## Vertical distance to travel from starting position.
@export var y_offset: float = 100.0
## The message to be displayed in the notification
@export var message: String

@onready var message_label = %Message
@onready var new_position = Vector2(position.x, y_offset)
signal complete()

func _ready():
	message_label.text = message
	modulate = Color(1,1,1,0)
	
	var tween = create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(transition_type)
	tween.tween_property(self, "modulate", Color(1,1,1,1), animation_length)
	tween.parallel().tween_property(self, "position", new_position, animation_length)
	
	await get_tree().create_timer(notification_length).timeout
	
	var fadeout_tween = create_tween()
	fadeout_tween.tween_property(self, "modulate", Color(1,1,1,0), animation_length/4)
	fadeout_tween.finished.connect(tween_finished)

## Remove notification after fade out is finished.
func tween_finished():
	complete.emit()
	queue_free()
