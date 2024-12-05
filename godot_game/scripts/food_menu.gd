extends ActionMenu

@export var nav_arrows: NavigationArrows;

var example_screen: MarginContainer
@onready var food_screens: HBoxContainer = find_child("FoodScreens")

var food_list: FoodList = load("res://resources/food_list.tres")
var drink_list: DrinkList = load("res://resources/drink_list.tres")


func _ready() -> void:
	super._ready()  # do last
	var ex = find_child("ExampleScreen")
	example_screen = ex.duplicate()
	ex.queue_free()
	
	setup_food_and_drink_buttons()
	
	## wait for queue_free to execute
	await get_tree().process_frame
	nav_arrows.calc_screen_count()

class ConsumablesScreen:
	var parent: HBoxContainer
	
	var food_grid: GridContainer
	var drink_grid: GridContainer
	
	var food_btn: CustomTooltipButton
	var drink_btn: CustomTooltipButton
	
	var food_count = 0
	var drink_count = 0
	
	func _init(prnt: HBoxContainer, example: MarginContainer) -> void:
		self.parent = prnt
		
		var margin := example.duplicate()
		self.food_grid = margin.get_child(0).get_child(0)
		self.drink_grid = margin.get_child(0).get_child(1)
		
		self.food_btn = food_grid.get_child(0)
		self.drink_btn = drink_grid.get_child(0)
		
		food_grid.remove_child(food_btn)
		drink_grid.remove_child(drink_btn)
		parent.add_child(margin)
	
	func add_food(food: FoodItem):
		var new_btn: Button = food_btn.duplicate()
		new_btn.text = food.name
		new_btn.icon = food.image
		food_grid.add_child(new_btn)
		food_count += 1
	
	func add_drink(drink: DrinkItem):
		var new_btn: Button = drink_btn.duplicate()
		new_btn.text = drink.name
		new_btn.icon = drink.image
		drink_grid.add_child(new_btn)
		drink_count += 1
	
	func is_food_full() -> bool:
		return food_count == 4
	
	func is_drink_full() -> bool:
		return drink_count == 4


func setup_food_and_drink_buttons():
	var all_screens: Array[ConsumablesScreen] = []
	all_screens.append(ConsumablesScreen.new(food_screens, example_screen))
	
	var food_on_screen = 0
	var drink_on_screen = 0
	
	for food_item in food_list.items:
		if all_screens[food_on_screen].is_food_full():
			food_on_screen += 1
			if len(all_screens) <= food_on_screen:
				all_screens.append(ConsumablesScreen.new(food_screens, example_screen))
		all_screens[food_on_screen].add_food(food_item)
	
	for drink_item in drink_list.items:
		if all_screens[drink_on_screen].is_drink_full():
			drink_on_screen += 1
			if len(all_screens) <= drink_on_screen:
				all_screens.append(ConsumablesScreen.new(food_screens, example_screen))
		all_screens[drink_on_screen].add_drink(drink_item)
