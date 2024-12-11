class_name FoodMenu extends ActionMenu

@export var nav_arrows: NavigationArrows;


@onready var food_screens: HBoxContainer = find_child("FoodScreens")
var example_screen: MarginContainer

const STRING_UNKNOWN = "amount: ???"
const STRING_KNOWN = "amount: %s"
const STRING_KNOWN_MODIFIED = "amount: %s (x%s)"

var food_list: FoodList = load("res://resources/food_list.tres")
var drink_list: DrinkList = load("res://resources/drink_list.tres")
var btn_shader = load("res://shaders/consumable_cooldown.gdshader")

var all_screens: Array[ConsumablesScreen] = []
var all_items: Dictionary = {}  # key: uid, value: item (Resource)
var all_buttons: Dictionary = {}  # key: uid: value: button_node
var btns_on_cooldown : Dictionary = {}  # keu: uid, value: time_started


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
	
	func add_food(food: FoodItem, consume_func: Callable, shader) -> CustomTooltipButton:
		var new_btn: CustomTooltipButton = food_btn.duplicate()
		new_btn.text = food.name
		new_btn.icon = food.image
		new_btn.tooltip_string = STRING_UNKNOWN
		
		var shader_child = new_btn.get_child(2)
		shader_child.material = ShaderMaterial.new()
		shader_child.material.shader = shader
		new_btn.connect("button_down", consume_func.bind(food))
		food_grid.add_child(new_btn)
		food_count += 1
		return new_btn
	
	func add_drink(drink: DrinkItem, consume_func: Callable, shader) -> CustomTooltipButton:
		var new_btn: CustomTooltipButton = drink_btn.duplicate()
		new_btn.text = drink.name
		new_btn.icon = drink.image
		new_btn.tooltip_string = STRING_UNKNOWN
		
		var shader_child = new_btn.get_child(2)
		shader_child.material = ShaderMaterial.new()
		shader_child.material.shader = shader
		new_btn.connect("button_down", consume_func.bind(drink))
		drink_grid.add_child(new_btn)
		drink_count += 1
		return new_btn
	
	func is_food_full() -> bool:
		return food_count == 4
	
	func is_drink_full() -> bool:
		return drink_count == 4


func setup_food_and_drink_buttons():
	all_screens.append(ConsumablesScreen.new(food_screens, example_screen))
	
	var food_on_screen = 0
	var drink_on_screen = 0
	
	for food_item in food_list.items:
		if all_screens[food_on_screen].is_food_full():
			food_on_screen += 1
			if len(all_screens) <= food_on_screen:
				all_screens.append(ConsumablesScreen.new(food_screens, example_screen))
		var btn = all_screens[food_on_screen].add_food(food_item, consume_item, btn_shader)
		
		var uid = Helpers.uid_str(food_item)
		all_buttons[uid] = btn
		all_items[uid] = food_item
	
	for drink_item in drink_list.items:
		if all_screens[drink_on_screen].is_drink_full():
			drink_on_screen += 1
			if len(all_screens) <= drink_on_screen:
				all_screens.append(ConsumablesScreen.new(food_screens, example_screen))
		var btn = all_screens[drink_on_screen].add_drink(drink_item, consume_item, btn_shader)
		
		var uid = Helpers.uid_str(drink_item)
		all_buttons[uid] = btn
		all_items[uid] = drink_item

func update_item_btn(uid: String, creature: Creature):
	var item: Resource = all_items[uid]
	var button: CustomTooltipButton = all_buttons[uid]
	
	var mult = -1
	var is_food = is_instance_of(item, FoodItem)
	
	## determine multiplier & show/hide preference icons
	if ((is_food and creature.get_food_preference(item) == creature.Preference.LIKES) 
			or (!is_food and creature.get_drink_preference(item) == creature.Preference.LIKES)):
		mult = creature.like_multiplier
		button.get_child(0).show()  # show star
	elif ((is_food and creature.get_food_preference(item) == creature.Preference.DISLIKES) 
			or (!is_food and creature.get_drink_preference(item) == creature.Preference.DISLIKES)):
		mult = creature.dislike_multiplier
		button.get_child(1).show()  # show frown
	
	if mult != -1:
		button.set_tooltip_string(STRING_KNOWN_MODIFIED % [item.amount, mult])
	else:
		button.set_tooltip_string(STRING_KNOWN % item.amount)

func consume_item(item: Resource):
	var uid: String = Helpers.uid_str(item)
	
	# cooldown
	if uid in btns_on_cooldown.keys():
		return
	else:
		btns_on_cooldown[uid] = {
			'cooldown': item.cooldown if item.override_auto_cooldown else item.amount * .2,
			'start_time': Time.get_unix_time_from_system()
		}
	all_buttons[uid].disabled = true
	
	# consume
	if is_instance_of(item, FoodItem):
		%ConsumablesManager.consume_food(item)
	else:
		%ConsumablesManager.consume_drink(item)

## progress the cooldowns
func _process(delta: float) -> void:
	super._process(delta)
	if btns_on_cooldown.size() > 0:
		var curr_time = Time.get_unix_time_from_system()
		for uid in btns_on_cooldown.keys():
			var btn: CustomTooltipButton = all_buttons[uid]
			var cooldown = btns_on_cooldown[uid]['cooldown']
			var started = btns_on_cooldown[uid]['start_time']
			
			var child = btn.get_child(2)
			var perc = (curr_time - started) / cooldown
			child.material.set("shader_parameter/percent", perc)
			if perc >= 1:
				btn.disabled = false
				btns_on_cooldown.erase(uid)
