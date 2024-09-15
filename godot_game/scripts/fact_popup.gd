extends MarginContainer

@onready var btn_sfx = find_parent("Game").find_child("BtnClick")
@onready var content = find_child("Content")
@onready var source = find_child("Source")
@onready var fact: Fact = load("res://resources/facts/example_fact.tres")

func _ready() -> void:
	content.text = fact.fact
	source.text = source.text % [fact.source]

func _on_cancel_button_down() -> void:
	btn_sfx.play()
	queue_free()


func _on_hidden() -> void:
	queue_free()
