class_name DrinkItem extends Resource

enum DrinkType {NEUTRAL, SOFT_DRINK, SHAKE, FRUIT_JIUCE, CAFFINE}

@export var name: String
@export var type: DrinkType
@export var amount: int = 50
@export var image: CompressedTexture2D
