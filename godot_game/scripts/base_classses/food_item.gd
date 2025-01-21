class_name FoodItem extends Resource

enum FoodType {NEUTRAL, BREAD, DEEP_FRIED, FRUIT, VEGETABLE, SWEET, SAVOURY, MEAT}

@export var name: String
@export var type: FoodType
@export var amount: int = 50
## override automatically generated cooldown
@export var override_auto_cooldown: bool = false
## in seconds
@export var overridden_cooldown: int = 30
@export var image: CompressedTexture2D
