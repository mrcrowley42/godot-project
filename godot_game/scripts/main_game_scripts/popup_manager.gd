@icon("res://icons/class-icons/bell-fill.svg")
class_name NotificationManager extends ScriptNode

@onready var basic_toast = preload("res://scenes/UiScenes/notification_basic.tscn")
@onready var adv_toast = preload("res://scenes/UiScenes/notification_adv.tscn")
@onready var grow_up_btn: NinePatchRect = find_child("GrowUpBtn")

@export var max_notifications: int = 3
@export var clippy_area: Node
@export var noti_pos: Control
@export var noti_parent: CanvasLayer

var child_count: int

## key: slot num, value: notification instance or null
var noti_slots = {}
var noti_queue = []

func _ready():
	for i in range(max_notifications):
		noti_slots[i] = null

func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		Globals.item_unlocked.connect(new_adv_notification)
		grow_up_btn.position.y += grow_up_btn.size.y * grow_up_btn.scale.y * 2.
		%Creature.ready_to_grow_up.connect(grow_up_btn.show_grow_up_btn)
		child_count = get_child_count()


func new_basic_notification(message: String):
	if clippy_area.clippy:
		return
	
	# waits until no other notifications are in the ui (a queue ¯\_(ツ)_/¯)
	while get_child_count() != child_count:
		await get_tree().create_timer(1).timeout
		if get_child_count() == child_count:
			continue
	
	var toast_size: Vector2 = basic_toast.instantiate().size
	var start_pos = Vector2((540-toast_size.x)/2,-toast_size.y+112)
	var notif = basic_toast.instantiate()
	notif.message = message
	notif.position = start_pos
	add_child(notif)
	print("ui basic notification displayed  '%s'" % notif.message)

func push_noti(instance: NotificationAdv, slot):
	instance.tween_in(slot)
	noti_slots[slot] = instance
	instance.removed.connect(remove_noti)
	print("ui adv notification displayed '%s'" % instance.message)

func remove_noti(slot):
	noti_slots[slot].queue_free()
	noti_slots[slot] = null
	if len(noti_queue) > 0:
		push_noti(noti_queue.pop_front(), slot)

func get_available_slot():
	for key in noti_slots.keys():
		if not noti_slots[key]:
			return key
	return null

func new_adv_notification(message: String, icon: Texture2D):
	var toast: NotificationAdv = adv_toast.instantiate()
	toast.btm_right = noti_pos.position
	toast.message = message
	toast.icon = icon
	noti_parent.add_child(toast)
	
	var slot = get_available_slot()
	if slot != null:
		push_noti(toast, slot)
	else:
		noti_queue.append(toast)
