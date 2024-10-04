extends Label

func _ready() -> void:
	Globals.item_unlocked.connect(update_text)
	update_text()


func update_text(_null=null):
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


func get_category_progress(fact_list, category, unlocked_facts) -> Array[int]:
	var facts = fact_list.filter(func(x): return x.category == category)
	var unlocked = facts.filter(func(x): return Helpers.uid_str(x) in unlocked_facts or x.unlocked)
	return [len(unlocked), len(facts)]
