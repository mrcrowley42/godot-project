extends MarginContainer

@export var general_grid: GridContainer
@export var minigame_grid: GridContainer
@export var completionist_grid: GridContainer

var all_achievements = preload("res://resources/all_achievements.tres").items
@onready var acheivenent_scene = preload("res://scenes/UiScenes/achievement_display.tscn")

func _notification(what):
	if what == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		var secrets = []
		
		for achievement in all_achievements:
			var btn: AchievementDisplay = acheivenent_scene.instantiate()
			btn.setup(achievement)
			if achievement.secret:
				secrets.append(btn)
				continue
			add_achivement_to_grid(btn)
		
		## do secrest last
		for secret in secrets:
			add_achivement_to_grid(secret)

func add_achivement_to_grid(ach: AchievementDisplay):
	if ach.achievement.category == Achievement.ACHIEVEMENT_CATEGORY.GENERAL:
		general_grid.add_child(ach)
	elif ach.achievement.category == Achievement.ACHIEVEMENT_CATEGORY.MINIGAME:
		minigame_grid.add_child(ach)
	else:
		completionist_grid.add_child(ach)
