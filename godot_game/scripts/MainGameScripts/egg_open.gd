class_name EggOpen extends ScriptNode

@export var skip_scene: bool = false
@export var choices_amnt: int = 3;
@export var existing_eggs: Array[EggEntry]

@export_subgroup("limit egg selection")
@export var limit_to_one: bool = false
@export var egg_index: int
@export var limit_to_many: bool = false
@export var egg_indexes: Array[int]

@onready var bg: NinePatchRect = find_child("BG")
@onready var trans_img: Sprite2D = find_child("Transition")
@onready var selection_title: RichTextLabel = find_child("SelectTitle")
@onready var selection_area: Control = find_child("SelectionArea")

const SMALL_EGG_SCALE: float = 1.5
const BASE_EGG_SCALE: float = 1.8

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
	var eggs_to_place: Array[EggEntry] = existing_eggs.slice(0, choices_amnt)
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
		var x_pos = scalar * i
		x_pos += scalar * .5  # center the eggs
		
		sprite.modulate.a = 0.
		sprite.texture = egg.image
		sprite.position = middle_pos + Vector2(x_pos, 0)
		sprite.scale = Vector2(SMALL_EGG_SCALE, SMALL_EGG_SCALE)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  # sharp image
		original_egg_positions.append(sprite.position)
		add_child(sprite)
		
		var diff = .2 * i
		tween(sprite, "modulate", Color.WHITE, 1. + diff, .5)
		tween(sprite, "position", Vector2(sprite.position.x, sprite.position.y - 20), 1.2 + diff, .6, Tween.EASE_OUT)
		tween(sprite, "position", Vector2(sprite.position.x, sprite.position.y), 1.4 + diff, .4, Tween.EASE_IN)
		var scale_tween = tween(sprite, "scale", Vector2(BASE_EGG_SCALE, BASE_EGG_SCALE), 2.2, .5)
		if i == eggs_to_place.size() - 1:  # set only on the last egg
			scale_tween.connect("finished", set_can_interact.bind(true))
		
		placed_egg_sprites.append(sprite)
	placed_eggs = eggs_to_place

func tween(obj, prop, val, delay=0., time=2., _ease=Tween.EASE_IN_OUT):
	var t = get_tree().create_tween()
	t.tween_property(obj, prop, val, time)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(_ease)\
			.set_delay(delay)
	return t

func set_can_interact(val: bool):
	can_interact = val
