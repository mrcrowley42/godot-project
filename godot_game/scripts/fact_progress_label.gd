extends Label

var og_text = ""


func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		og_text = text
		Globals.item_unlocked.connect(update_text)
		update_text()


func update_text(_null=null):
	var unlocked_total = 0
	var facts_total = 0
	for category in Fact.FactCategory.values():
		var progress = Globals.get_fact_category_progress(category)
		unlocked_total += progress[0]
		facts_total += progress[1]
	
	var percent = floor((float(unlocked_total) / float(facts_total)) * 100)
	text = str(percent) + og_text
	
	if percent == 100:
		text += "!"
