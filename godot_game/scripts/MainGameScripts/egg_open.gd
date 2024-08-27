class_name EggOpen extends ScriptNode

@export var skip_scene: bool = false
@export var choices_amnt: int = 3;
@export var existing_eggs: Array[EggEntry]

@export_subgroup("limit egg selection")
@export var limit_to_one: bool = false
@export var egg_index: int
@export var limit_to_many: bool = false
@export var egg_indexes: Array[int]

@onready var selection_title: RichTextLabel = find_child("SelectTitle")
@onready var selection_area: Control = find_child("SelectionArea")

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
		sprite.texture = egg.image
		sprite.position = middle_pos + Vector2(x_pos, 0)
		sprite.scale = Vector2(BASE_EGG_SCALE, BASE_EGG_SCALE)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  # no blur
		original_egg_positions.append(sprite.position)
		add_child(sprite)
		placed_egg_sprites.append(sprite)
	placed_eggs = eggs_to_place


func tween(obj, prop, val, delay=0):
	get_tree().create_tween()\
		.tween_property(obj, prop, val, 2.)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(delay)
