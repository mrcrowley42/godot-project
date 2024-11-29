class_name FoodItem extends Resource

enum FoodType {NEUTRAL, BREAD, DEEP_FRIED, FRUIT, VEGETABLE, SWEET, SAVOURY}

@export var name: String
@export var type: FoodType
@export var amount: int = 50
@export var image: CompressedTexture2D
