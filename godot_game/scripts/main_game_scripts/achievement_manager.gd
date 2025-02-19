class_name AchievementManager extends ScriptNode

@export var general_grid: GridContainer
@export var minigame_grid: GridContainer
@export var completionist_grid: GridContainer
@export var perc_label: Label

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
		
		## do secrest ones last
		for secret in secrets:
			add_achivement_to_grid(secret)
		update_progress_label()
		Globals.achievement_unlocked.connect(update_progress_label)

func add_achivement_to_grid(ach: AchievementDisplay):
	if ach.achievement.category == Achievement.ACHIEVEMENT_CATEGORY.GENERAL:
		general_grid.add_child(ach)
	elif ach.achievement.category == Achievement.ACHIEVEMENT_CATEGORY.MINIGAME:
		minigame_grid.add_child(ach)
	else:
		completionist_grid.add_child(ach)

func update_progress_label(_uid=-1):
	var total_count = len(all_achievements)
	var current_count = len(DataGlobals.get_global_metadata_value(DataGlobals.UNLOCKED_ACHIEVEMENTS))
	var perc = floor((float(current_count) / float(total_count)) * 100.)
	perc_label.text = str(perc) + "% complete" + ("!" if perc == 100 else "")
