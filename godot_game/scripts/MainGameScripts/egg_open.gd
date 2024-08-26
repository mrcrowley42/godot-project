class_name EggOpen extends ScriptNode

@export var skip_scene: bool = false
@export var choices_amnt: int = 3;
@export var existing_eggs: Array[EggEntry]

@export_subgroup("limit egg selection")
@export var limit_to_one: bool = false
@export var egg_index: int

@onready var selection_title: RichTextLabel = find_child("SelectTitle")
@onready var selection_area: Control = find_child("SelectionArea")

var egg_scale: float = 1.5;


func _ready():
	if skip_scene:
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/GameScenes/main.tscn")
		return
	
	selection_title.modulate.a = 0
	tween(selection_title, "modulate", Color.WHITE)
	
	var middle_pos = selection_area.position + Vector2(0, selection_area.size.y * .5)
	var scalar: float = selection_area.size.x * (1. / choices_amnt)
	for i: int in existing_eggs.size():
		var egg: EggEntry = existing_eggs[i]
		var sprite: Sprite2D = Sprite2D.new()
		var x_pos = scalar * i
		x_pos += scalar * .5  # center the eggs
		sprite.texture = egg.image
		sprite.position = middle_pos + Vector2(x_pos, 0)
		sprite.scale = Vector2(egg_scale, egg_scale)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  # no blur
		add_child(sprite)


func tween(obj, prop, val, delay=0):
	get_tree().create_tween().tween_property(obj, prop, val, 2.).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_delay(delay)
