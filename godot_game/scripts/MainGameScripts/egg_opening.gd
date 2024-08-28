class_name EggOpen extends ScriptNode

@export var skip_scene: bool = false
@export var existing_eggs: Array[EggEntry]

@export_subgroup("limit egg selection")
@export var sequence_start_inx: int = 0
@export var choices_amnt: int = 3;
@export var limit_to_one: bool = false
@export var egg_index: int
@export var limit_to_many: bool = false
@export var egg_indexes: Array[int]

@onready var bg: NinePatchRect = find_child("BG")
@onready var trans_img: Sprite2D = find_child("Transition")
@onready var selection_title: RichTextLabel = find_child("SelectTitle")
@onready var selection_area: Control = find_child("SelectionArea")
@onready var shader_area: ColorRect = find_child("shader")
@onready var egg_desc: RichTextLabel = find_child("EggDesc")
@onready var back_btn: NinePatchRect = find_child("BackButton")

const OFFSET: Vector2 = Vector2(0, -20)
const EPSILON: float = 0.0001
const STRING_SELECT_YOUR_EGG: String = "Select your egg"
const NO_EGG_FORMAT_STRING: String = "[center]%s"
const EGG_FORMAT_STRING: String = "[center][u]%s[/u]\nHatches: %s"

const SMALL_EGG_SCALE: Vector2 = Vector2(1.5, 1.5)
const BASE_EGG_SCALE: Vector2 = Vector2(1.8, 1.8)
const HOVER_EGG_SCALE: Vector2 = Vector2(2., 2.)
const BASE_SELECTED_EGG_SCALE: Vector2 = Vector2(2.2, 2.2)

var selection_area_center: Vector2
var select_title_text: String
var move_buffers: Array[FloatBuffer] = []
var can_interact: bool = false  # turn off while tweening stuff around

var placed_eggs: Array[EggEntry] = []
var placed_egg_sprites: Array[Control] = []
var original_egg_positions: Array[Vector2] = []
var selected_egg_inx = null  # int

func _ready():
	if skip_scene:
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/GameScenes/main.tscn")
		return
	
	# setup
	back_btn.visible = false
	back_btn.connect("gui_input", back_btn_input)
	select_title_text = selection_title.text
	selection_title.text = select_title_text % [STRING_SELECT_YOUR_EGG]
	
	# transition
	trans_img.position = bg.position + (bg.size * bg.scale) * .5
	tween(trans_img, "position", trans_img.position + Vector2(0, 1000))
	
	selection_area_center = selection_area.position + selection_area.size * .5
	spawn_eggs()

## structure of egg:
## - Control  (scale & move this)
##   - Sprite2D  (rotate this)
##   - Area2D  (mouse detection)
##     - CollisionShape2D
func spawn_eggs():
	# find the eggs to be placed
	var eggs_to_place: Array[EggEntry] = existing_eggs.slice(sequence_start_inx, sequence_start_inx + choices_amnt)
	if limit_to_one:
		eggs_to_place = [existing_eggs[egg_index]]
	if limit_to_many:
		eggs_to_place = []
		for i: int in egg_indexes:
			eggs_to_place.append(existing_eggs[i])

	var middle_pos = selection_area.position + Vector2(0, selection_area.size.y * .5)
	var scalar: float = selection_area.size.x * (1. / eggs_to_place.size())
	
	for i: int in eggs_to_place.size():
		var egg: EggEntry = eggs_to_place[i]
		var sprite_c: Control = Control.new()
		var sprite: Sprite2D = Sprite2D.new()
		
		# set default values
		var x_pos = scalar * i
		x_pos += scalar * .5  # center the eggs
		sprite.texture = egg.image
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  # sharp image
		sprite.position = -OFFSET  # counter the offset
		sprite.offset = OFFSET
		sprite_c.modulate.a = 0.
		sprite_c.position = middle_pos + Vector2(x_pos, 0)
		sprite_c.scale = SMALL_EGG_SCALE
		original_egg_positions.append(sprite_c.position)
		
		# initialising
		add_child(sprite_c)
		sprite_c.add_child(sprite)
		add_collision_areas(sprite_c, sprite, i)
		do_opening_animation(sprite_c, i, i == eggs_to_place.size() - 1)
		
		placed_egg_sprites.append(sprite_c)
	placed_eggs = eggs_to_place

func add_collision_areas(sprite_cl: Control, sprite: Sprite2D, i: int):
	var area_2d: Area2D = Area2D.new()
	var coll_shape: CollisionShape2D = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	sprite_cl.add_child(area_2d)
	area_2d.add_child(coll_shape)
	area_2d.monitorable = false  # not nessecary
	circle.radius = sprite.texture.get_size().x * sprite.scale.x * .2  # around the eggs size
	coll_shape.shape = circle
	area_2d.connect("mouse_entered", mouse_entered.bind(i))
	area_2d.connect("mouse_exited", mouse_exited.bind(i))
	area_2d.connect("input_event", mouse_clicked.bind(i))

func do_opening_animation(sprite_c: Control, i: int, is_last_egg: bool):
	var diff = .2 * i
	tween(sprite_c, "modulate", Color.WHITE, 1. + diff, .5)  # fade in
	tween(sprite_c, "position", Vector2(sprite_c.position.x, sprite_c.position.y - 20), 1.2 + diff, .6, Tween.EASE_OUT)  # move up
	var move_down_tween = tween(sprite_c, "position", Vector2(sprite_c.position.x, sprite_c.position.y), 1.4 + diff, .4, Tween.EASE_IN)  # move down
	if is_last_egg:
		move_down_tween.connect("finished", end_opening_animation)

func end_opening_animation():
	# scale all placed eggs up
	for i: int in placed_egg_sprites.size():
		var scale_tween = tween(placed_egg_sprites[i], "scale", BASE_EGG_SCALE, 0., .5)
		if i == placed_eggs.size() - 1:  # only on the last egg
			scale_tween.connect("finished", manual_mouse_check)

## generic function
func tween(obj, prop, val, delay=0., time=2., _ease=Tween.EASE_IN_OUT):
	var t = get_tree().create_tween()
	t.tween_property(obj, prop, val, time)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(_ease)\
			.set_delay(delay)
	return t

func manual_mouse_check(sprite_c: Control = null):
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	set_can_interact(true)
	
	var is_mouse_within = func(s: Control) -> bool:
		var dist: float = (mouse_pos - s.position).length()
		var area: Area2D = s.get_child(1)
		var radius: float = area.get_child(0).shape.radius * (s.scale.x * .9)  # scale area down just a little
		return dist < radius
	
	# have to do a manual mouse check :( whatever
	if sprite_c == null:  # check placed eggs
		for i: int in placed_egg_sprites.size():
			if (is_mouse_within.call(placed_egg_sprites[i])):
				mouse_entered(i)
	elif is_mouse_within.call(sprite_c):  # check selected egg
		print("within")

func set_can_interact(val: bool):
	can_interact = val

func mouse_entered(i: int):
	# entered a placed egg
	if selected_egg_inx == null and can_interact:
		var sprite_c: Control = placed_egg_sprites[i]
		tween(sprite_c, "scale", HOVER_EGG_SCALE, 0., .5, Tween.EASE_OUT)
		set_egg_desc(i)

func mouse_exited(i: int):
	# entered a placed egg
	if selected_egg_inx == null and can_interact:
		var sprite_c: Control = placed_egg_sprites[i]
		tween(sprite_c, "scale", BASE_EGG_SCALE, 0., .5, Tween.EASE_OUT)
		set_egg_desc()
		manual_mouse_check()  # in case there are overlapping eggs

func mouse_clicked(_viewport, event: InputEvent, _shape_idx, i):
	if selected_egg_inx == null and can_interact and event.is_pressed():
		select_egg(placed_eggs[i], i)

## when hovering over a placed egg
func set_egg_desc(i: int = -1):
	if i < 0:
		egg_desc.text = NO_EGG_FORMAT_STRING % ["..."]
		return
	
	var egg: EggEntry = placed_eggs[i]
	egg_desc.text = EGG_FORMAT_STRING % [egg.name, "???"]

## when one egg is selected from placed eggs
func select_egg(egg: EggEntry, inx: int):
	can_interact = false
	selected_egg_inx = inx
	
	# set labels
	selection_title.text = select_title_text % [egg.name]
	egg_desc.text = ""
	back_btn.visible = true
	back_btn.modulate.a = 0
	tween(back_btn, "modulate", Color.WHITE, 0., 1.)
	
	tween(shader_area.material, "shader_parameter/color", Vector4(0, 0, 1, 1), 0., 1.)
	tween_sprite_to_goal(selection_area_center)  # move to center
	
	# fade out other eggs
	for i: int in placed_egg_sprites.size():
		if i != inx:
			var sprite_c: Control = placed_egg_sprites[i]
			tween(sprite_c, "modulate", Color(1, 1, 1, 0), 0., .4, Tween.EASE_OUT)  # fade out
			tween(sprite_c, "position", Vector2(sprite_c.position.x, sprite_c.position.y + 20), 0., .3, Tween.EASE_OUT)  # move down

func de_select_egg():
	selected_egg_inx = null
	set_egg_desc()
	manual_mouse_check()  # do check on all placed eggs

func tween_sprite_to_goal(goal: Vector2, scale_goal: Vector2 = BASE_SELECTED_EGG_SCALE, end_selection: bool = false):
	var end_movement = func(sp: Control):
		move_buffers.clear()
		de_select_egg() if end_selection else manual_mouse_check(sp)
	
	tween(placed_egg_sprites[selected_egg_inx], "scale", SMALL_EGG_SCALE, 0., .2, Tween.EASE_OUT)  # scale down
	
	var s: Control = placed_egg_sprites[selected_egg_inx]
	move_buffers = [FloatBuffer.new(s.position.x), FloatBuffer.new(s.position.y)]
	tween(move_buffers[0], "value", goal.x, 0., 1., Tween.EASE_OUT)  # x pos to center
	tween(move_buffers[1], "value", goal.y - 50, 0., .6, Tween.EASE_OUT)  # up
	tween(move_buffers[1], "value", goal.y, 0.2, .4, Tween.EASE_IN)  # down
	var scale_tween = tween(s, "scale", scale_goal, .12, .5, Tween.EASE_IN)  # scale up
	scale_tween.connect("finished", end_movement.bind(s))  # finish movement event

## bring back egg selection
func back_btn_input(event: InputEvent):
	if can_interact and selected_egg_inx != null and event.is_pressed():
		set_can_interact(false)
		tween(back_btn, "modulate", Color(1, 1, 1, 0), 0., .5, Tween.EASE_OUT)  # fade out back btn
		tween_sprite_to_goal(original_egg_positions[selected_egg_inx], BASE_EGG_SCALE, true)
		
		selection_title.text = select_title_text % [STRING_SELECT_YOUR_EGG]
		tween(shader_area.material, "shader_parameter/color", Vector4(0, 0, 0, 1), 0., 1.)
		
		# fade back in other eggs
		for i: int in placed_egg_sprites.size():
			if i != selected_egg_inx:
				var sprite_c: Control = placed_egg_sprites[i]
				tween(sprite_c, "modulate", Color(1, 1, 1, 1), 0., .4, Tween.EASE_OUT)  # fade in
				tween(sprite_c, "position", original_egg_positions[i], 0., .3, Tween.EASE_OUT)  # move up

func _process(_delta):
	# bob eggs slowly
	if selected_egg_inx == null:  # do all
		for i: int in placed_egg_sprites.size():
			var s = sin(Time.get_unix_time_from_system() - (1. * i)) * 6
			placed_egg_sprites[i].position.y = original_egg_positions[i].y + s
	elif can_interact:  # do only selected
		var s = sin(Time.get_unix_time_from_system()) * 6
		placed_egg_sprites[selected_egg_inx].position.y = original_egg_positions[selected_egg_inx].y + s
	
	# move selected egg animation
	if move_buffers.size() > 0 and selected_egg_inx != null:
		var new_p = Vector2(move_buffers[0].value, move_buffers[1].value)
		placed_egg_sprites[selected_egg_inx].position = new_p

class FloatBuffer:
	var value = 0
	func _init(v):
		value = v
