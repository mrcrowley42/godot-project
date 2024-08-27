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
@onready var egg_desc: RichTextLabel = find_child("EggDesc")

const SMALL_EGG_SCALE: Vector2 = Vector2(1.5, 1.5)
const BASE_EGG_SCALE: Vector2 = Vector2(1.8, 1.8)
const HOVER_EGG_SCALE: Vector2 = Vector2(2., 2.)

var selected_egg: EggEntry = null
var end_time: float = 0  # end of animation time
var can_interact: bool = false  # off while tweening stuff around
var placed_eggs: Array[EggEntry] = []
var placed_egg_sprites: Array[Sprite2D] = []
var original_egg_positions: Array[Vector2] = []


func _ready():
	if skip_scene:
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/GameScenes/main.tscn")
		return
	
	trans_img.position = bg.position + (bg.size * bg.scale) * .5
	tween(trans_img, "position", trans_img.position + Vector2(0, 1000))
	
	place_eggs()

func place_eggs():
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
		var sprite: Sprite2D = Sprite2D.new()
		
		# set default values
		var x_pos = scalar * i
		x_pos += scalar * .5  # center the eggs
		sprite.modulate.a = 0.
		sprite.texture = egg.image
		sprite.position = middle_pos + Vector2(x_pos, 0)
		sprite.scale = SMALL_EGG_SCALE
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  # sharp image
		original_egg_positions.append(sprite.position)
		
		# initialising
		add_child(sprite)
		add_collision_areas(sprite, i)
		begin_opening_animation(sprite, i, i == eggs_to_place.size() - 1)
		
		placed_egg_sprites.append(sprite)
	placed_eggs = eggs_to_place

func add_collision_areas(sprite: Sprite2D, i: int):
	var area_2d: Area2D = Area2D.new()
	var coll_shape: CollisionShape2D = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	sprite.add_child(area_2d)
	area_2d.add_child(coll_shape)
	area_2d.monitorable = false  # simply not nessecary
	circle.radius = sprite.texture.get_size().x * sprite.scale.x * .15
	coll_shape.shape = circle
	area_2d.connect("mouse_entered", mouse_entered.bind(i))
	area_2d.connect("mouse_exited", mouse_exited.bind(i))
	area_2d.connect("input_event", mouse_clicked.bind(i))

func begin_opening_animation(sprite: Sprite2D, i: int, is_last_egg: bool):
	var diff = .2 * i
	tween(sprite, "modulate", Color.WHITE, 1. + diff, .5)
	tween(sprite, "position", Vector2(sprite.position.x, sprite.position.y - 20), 1.2 + diff, .6, Tween.EASE_OUT)
	tween(sprite, "position", Vector2(sprite.position.x, sprite.position.y), 1.4 + diff, .4, Tween.EASE_IN)
	var scale_tween = tween(sprite, "scale", BASE_EGG_SCALE, 2.2, .5)
	if is_last_egg:  # set only on the last egg
		scale_tween.connect("finished", force_check_mouse)

func tween(obj, prop, val, delay=0., time=2., _ease=Tween.EASE_IN_OUT):
	var t = get_tree().create_tween()
	t.tween_property(obj, prop, val, time)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(_ease)\
			.set_delay(delay)
	return t

func force_check_mouse():
	set_can_interact(true)
	end_time = Time.get_unix_time_from_system()
	
	# have to do a manual mouse check :( whatever
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	for i: int in placed_egg_sprites.size():
		var sprite: Sprite2D = placed_egg_sprites[i]
		var dist: float = (mouse_pos - sprite.position).length()
		var radius: float = sprite.get_child(0).get_child(0).shape.radius * (sprite.scale.x * .8)
		if (dist < radius):
			mouse_entered(i)

func set_can_interact(val: bool):
	can_interact = val

func mouse_entered(i: int):
	if can_interact:
		var sprite: Sprite2D = placed_egg_sprites[i]
		tween(sprite, "scale", HOVER_EGG_SCALE, 0., .5, Tween.EASE_OUT)
		set_egg_desc(i)

func mouse_exited(i: int):
	if can_interact:
		var sprite: Sprite2D = placed_egg_sprites[i]
		tween(sprite, "scale", BASE_EGG_SCALE, 0., .5, Tween.EASE_OUT)
		set_egg_desc()

func mouse_clicked(_viewport, event: InputEvent, _shape_idx, i):
	if can_interact and event.is_pressed():
		do_select_egg(placed_eggs[i], i)

func set_egg_desc(i: int = -1):
	var empty_format = "[center]%s"
	if i < 0:
		egg_desc.text = empty_format % ["..."]
		return
	
	var egg_format = "[center][u]%s[/u]\nHatches: %s"
	var egg: EggEntry = placed_eggs[i]
	egg_desc.text = egg_format % [egg.name, "???"]

func do_select_egg(egg: EggEntry, i: int):
	selected_egg = egg
	print(egg.name, " ", i)

func _process(_delta):
	for i: int in placed_egg_sprites.size():
		var s = sin(Time.get_unix_time_from_system() - (.5 * i)) * 6
		var sprite: Sprite2D = placed_egg_sprites[i]
		sprite.position.y = original_egg_positions[i].y + s
