extends MarginContainer

@export var heading: Node
@export var description: Node
@export var preview: Sprite2D
@export var hatches_grid: GridContainer
@onready var btn_sfx = find_parent("Game").find_child("BtnClick")
var egg: EggEntry


func _on_back_button_down() -> void:
	btn_sfx.play()
	queue_free()

func _on_hidden() -> void:
	queue_free()

func setup():
	heading.text = "%s" % egg.name
	description.text = "Hatch creatures from this egg."
	preview.texture = egg.image
	
	for baby_entry: EggCreatureEntry in egg.hatches:
		var baby: CreatureBaby = baby_entry.creature_baby
		var scene: Button = load("res://scenes/UiScenes/baby_listing.tscn").instantiate()
		scene.setup(baby)
		scene.custom_minimum_size = Vector2(70, 90)
		scene.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scene.size_flags_vertical = Control.SIZE_EXPAND_FILL
		hatches_grid.add_child(scene)
