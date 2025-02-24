class_name ConsumablesManager extends ScriptNode

@export var creature: Creature
@export var food_menu: FoodMenu

@export var food_items: FoodList
@export var drink_items: DrinkList

@export var all_foods_ach: Achievement

var consumables_tried: Array
var total_colsumables_count: int = 0


func consume_food(food_item: FoodItem):
	creature.consume_food(food_item)
	consume_item(food_item)

func consume_drink(drink_item: DrinkItem):
	creature.consume_drink(drink_item)
	consume_item(drink_item)

func consume_item(item: Resource):
	var uid = Helpers.uid_str(item)
	if uid not in consumables_tried:
		consumables_tried.append(uid)
		food_menu.update_item_btn(uid, creature)
	
	if len(consumables_tried) == total_colsumables_count:
		Globals.unlock_achievement(all_foods_ach)

func get_save_uid():
	return DataGlobals.SAVE_CONSUMABLES_MANAGER_UID

func save():
	return {"consumables_tried": consumables_tried}

func load(data):
	consumables_tried = data["consumables_tried"]

func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		total_colsumables_count = len(food_items.items) + len(drink_items.items)
		for uid in consumables_tried:
			food_menu.update_item_btn(uid, creature)
