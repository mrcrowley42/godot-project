extends MarginContainer

@export var heading: Node
@export var preview: AnimatedSprite2D
@export var emote_btn: OptionButton

@export var lifestage_btn: OptionButton
@onready var btn_sfx = find_parent("Game").find_child("BtnClick")
@onready var showcase_scene = load("res://scenes/UiScenes/creature_showcase.tscn")
var creature: CreatureType


func _on_back_button_down() -> void:
	btn_sfx.play()
	queue_free()


func _on_hidden() -> void:
	queue_free()

func update_animation(anim_name):
	preview.animation = anim_name

func setup():
	if not creature:
		return
	heading.text = "%s" % creature.name
	preview.sprite_frames = creature.baby.sprite_frames
	preview.autoplay = "idle"
	
	#emote_btn.remove_item(0)
	for anim_name in creature.baby.sprite_frames.get_animation_names():
		emote_btn.add_item(anim_name)
	
	update_animation("idle")
	#category_btn.item_selected.emit(0)


func _on_button_button_down() -> void:
	var showcase = showcase_scene.instantiate()
	showcase.creature = creature
	add_child(showcase)


func _on_stage_btn_item_selected(_index: int) -> void:
	pass # Replace with function body.


func _on_emote_btn_item_selected(index: int) -> void:
	if index == 0:
		return
	var anim = emote_btn.get_item_text(index)
	update_animation(anim)
