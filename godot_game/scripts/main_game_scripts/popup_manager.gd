@icon("res://icons/class-icons/bell-fill.svg")
class_name NotificationManager extends ScriptNode

@onready var basic_toast = preload("res://scenes/UiScenes/notification_basic.tscn")
@onready var adv_toast = preload("res://scenes/UiScenes/notification_adv.tscn")
@onready var grow_up_btn: NinePatchRect = find_child("GrowUpBtn")

@export var clippy_area: Node

var child_count: int

func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		Globals.item_unlocked.connect(new_basic_notification)
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


func new_adv_notification():
	print("ui adv notification displayed")
