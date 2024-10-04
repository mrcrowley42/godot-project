extends Label

func _ready() -> void:
	update_text()


func update_text():
	var base_text = ""
	var unlocked_facts = DataGlobals.load_metadata()['unlocked_facts']
	var fact_list = load("res://resources/fact_list.tres").facts
	
	for category in Fact.FactCategory.values():
		var progress = get_category_progress(fact_list, category, unlocked_facts)
		base_text += str(Fact.FactCategory.keys()[category]).to_lower().capitalize()
		base_text += ": "
		base_text += str(progress[0]) + "/"
		base_text += str(progress[1]) + "\n"

	text = base_text


func get_category_progress(fact_list, category, unlocked_facts):
	var facts = fact_list.filter(func(x): return x.category == category)
	var unlocked = facts.filter(func(x): return Helpers.uid_str(x) in unlocked_facts or x.unlocked)

	return [len(unlocked), len(facts)]
