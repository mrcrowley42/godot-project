@icon("res://icons/class-icons/bell-fill.svg")
class_name NotificationManager extends ScriptNode

@onready var toast = preload("res://scenes/UiScenes/basic_notification.tscn")
@onready var grow_up_btn: NinePatchRect = find_child("GrowUpBtn")

var og_pos: Vector2
var child_count: int 

func _ready():
	og_pos = grow_up_btn.position
	grow_up_btn.position.y += grow_up_btn.size.y * grow_up_btn.scale.y * 2.
	%Creature.ready_to_grow_up.connect(show_grow_up_btn)
	child_count = get_child_count()

## Creates a toast notification with the passed string.
func new_notification(message: String, type: PackedScene=toast) -> void:
	# Create an instance so we can grab the size of the popup.
	var toast2 = type.instantiate()
	# spawn notification in the horizontal centre and just above the top of screen.
	var start_pos = Vector2((540-toast2.size.x)/2,-toast2.size.y+112)

	# Checks every second that the node has no children before executing
	# Seems to queue consecutive calls ¯\_(ツ)_/¯
	while get_child_count() != child_count:
		await get_tree().create_timer(1).timeout
		if get_child_count() == child_count:
			continue
	var notif = toast.instantiate()
	notif.message = message
	notif.position = start_pos
	add_child(notif)

func show_grow_up_btn():
	get_tree().create_tween().tween_property(
		grow_up_btn, "position", og_pos, 1.
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func _on_grow_up_btn_gui_input(event: InputEvent):
	if event.is_pressed() and %Creature.is_ready_to_grow_up:
		get_tree().root.propagate_notification(Globals.NOFITICATION_GROW_TO_ADULT_SCENE)
