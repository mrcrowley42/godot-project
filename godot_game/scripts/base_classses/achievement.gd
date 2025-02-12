class_name Achievement extends Resource

enum ACHIEVEMENT_CATEGORY {GENERAL, MINIGAME, COMPLETIONIST}

@export var title: String
@export var hint: String
@export var category: ACHIEVEMENT_CATEGORY
@export var secret: bool
@export var image: Texture2D
