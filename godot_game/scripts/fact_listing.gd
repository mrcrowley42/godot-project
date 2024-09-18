extends MarginContainer

@onready var btn_sfx = find_parent("Game").find_child("BtnClick")
@onready var heading = find_child("Category")
@onready var fact_container = find_child("FactList")

var category: Fact.FactCategory

func _ready() -> void:
	heading.text = Fact.FactCategory.keys()[category] 


func _on_cancel_button_down() -> void:
	btn_sfx.play()
	queue_free()


func _on_hidden() -> void:
	queue_free()


func add_facts() -> void:
	
	print("does this even work")
	## yep facts
	#add_child(fact_btn)
