class_name AchievementDisplay extends PanelContainer

var achievement: Achievement
var btn: CustomTooltipButton

const LOCKED_MODULATE: Color = Color(0.156, 0.156, 0.156, 1)

func setup(the_achievement: Achievement):
	achievement = the_achievement
	btn = get_child(0)
	update_locked()
	Globals.achievement_unlocked.connect(update_locked)

func update_locked(new_achievement_uid = null):
	var unlocked_achievements: Array = DataGlobals.get_global_metadata_value(DataGlobals.UNLOCKED_ACHIEVEMENTS)
	var uid = Helpers.uid_str(achievement)
	var is_unlocked = unlocked_achievements.has(uid)
	
	if achievement.image:
		btn.icon = achievement.image
	
	if is_unlocked:
		btn.tooltip_string = achievement.title + "\n\n(" + achievement.hint + ")"
		btn.modulate = Color(1, 1, 1, 1)
	else:
		btn.tooltip_string = "It's a secret" if achievement.secret else achievement.hint
		btn.modulate = LOCKED_MODULATE
	
	## !
	if new_achievement_uid != null and uid == new_achievement_uid:
		var sprite: Sprite2D = Globals.spawn_exclamation_point(self)
		btn.mouse_entered.connect(remove_sprite.bind(sprite))

func remove_sprite(child):
	remove_child(child)
	btn.mouse_entered.disconnect(remove_sprite)
