extends MarginContainer

@onready var btn_sfx = find_parent("Game").find_child("BtnClick")
@onready var heading = find_child("Category")
var category: Fact.FactCategory

func _ready() -> void:
	heading.text = Fact.FactCategory.keys()[category] 
	#content.text = fact.fact
	#source.text = source.text % [fact.source]

func _on_cancel_button_down() -> void:
	btn_sfx.play()
	queue_free()

func _on_hidden() -> void:
	queue_free()

func add_facts():
	pass
	## yep facts
	#add_child(fact_btn)
