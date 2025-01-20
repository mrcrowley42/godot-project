class_name DrinkItem extends Resource

enum DrinkType {NEUTRAL, SOFT_DRINK, SHAKE_OR_SWEET, FRUIT_JUICE, CAFFINE, NUCLEAR_ACID}

@export var name: String
@export var type: DrinkType
@export var amount: int = 50
## override automatically generated cooldown
@export var override_auto_cooldown: bool = false
## in seconds
@export var overridden_cooldown: int = 30
@export var image: CompressedTexture2D
