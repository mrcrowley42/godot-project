extends MarginContainer

@export var heading: Node
@onready var btn_sfx = find_parent("Game").find_child("BtnClick")

#var category: Fact.FactCategory
#var facts = load("res://resources/fact_list.tres")

func _ready() -> void:
	pass
	#heading.text = "Facts: %s" % Fact.FactCategory.keys()[category]


func _on_back_button_down() -> void:
	btn_sfx.play()
	queue_free()


func _on_hidden() -> void:
	queue_free()


func add_facts() -> void:
	pass
	#for fact in facts.facts:
		#if fact.category == category:
			#var btn = fact_btn_scene.instantiate()
			#btn.fact_to_display = fact
			#btn.update_locked()
			#fact_container.add_child(btn)