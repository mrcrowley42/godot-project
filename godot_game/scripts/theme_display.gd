extends GridContainer

const BTN_SIZE: Vector2 = Vector2(172, 80)
@export var theme_manager: UiThemeManager
@export var ach_man: AchievementManager
const btn_theme_group = preload("res://resources/theme_btn_group.tres")
const btn_theme = preload("res://themes/cosmetic_btn_theme.tres")

## Class that describes UI theme button.
class UiThemeButton extends CustomTooltipButton:
	var ui_theme
	var ach_man: AchievementManager
	func _init(_ui_theme: UiTheme, selected: bool):
		self.direction = DIRECTION.DOWN
		self.custom_minimum_size = BTN_SIZE
		self.size = BTN_SIZE
		self.expand_icon = false
		self.ui_theme = _ui_theme
		self.text = _ui_theme.theme_name
		self.toggle_mode = true
		self.text = ui_theme.theme_name
		self.button_pressed = selected
		theme = load("res://themes/menu_btn_dark.tres")
		add_theme_font_size_override("font_size", 20)
		add_theme_color_override("font_color", ui_theme.primary)
		add_theme_color_override("font_pressed_color", ui_theme.screen_tint)
		add_theme_color_override("font_hover_color", ui_theme.screen_tint)
		
		
		var box = StyleBoxFlat.new()
		box.bg_color = ui_theme.bg
		box.set_corner_radius_all(10)
		box.set_border_width_all(3)
		box.border_color = ui_theme.outline
		self.add_theme_stylebox_override("normal", box)
		self.add_theme_stylebox_override("hover", box)
		self.add_theme_stylebox_override("disabled", box)
		var box2 = StyleBoxFlat.new()
		box2.set_corner_radius_all(10)
		box2.set_border_width_all(3)
		#box2.set_expand_margin_all(2)
		box2.border_color = ui_theme.screen_tint
		
		box2.bg_color = ui_theme.bg
		self.add_theme_stylebox_override("pressed", box2)
		
		#self.add_theme_stylebox_override("focus", box2)
		button_group = btn_theme_group
		update_locked()
		Globals.theme_unlocked.connect(update_locked)

	## Action when button is pressed.
	func _pressed():
		var manager = find_parent("Game").find_child("UI_Theme_Manager")
		manager.set_theme(self.ui_theme)
		var sound_click = find_parent("Game").find_child("BtnClick")
		sound_click.play()
		DataGlobals.save_settings_data()
		ach_man.customise_everything_counter(ach_man.CUSTOMISATIONS.THEME)

	func update_locked(new_theme_uid = null):
		var unlocked_items = DataGlobals.get_global_metadata_value(DataGlobals.UNLOCKED_THEMES)
		var uid = Helpers.uid_str(self.ui_theme)
		self.disabled = false if self.ui_theme.unlocked else not uid in unlocked_items
		self.tooltip_string = ui_theme.hint if disabled else ""
		self.text = "?" if self.disabled else self.ui_theme.theme_name
		var box = self.get_theme_stylebox("pressed")
		if not self.disabled:
			self.add_theme_stylebox_override("focus", box)
		
		if new_theme_uid != null and uid == new_theme_uid:
			var sprite: Sprite2D = Globals.spawn_exclamation_point(self)
			button_down.connect(remove_sprite.bind(sprite))
	
	func remove_sprite(child):
		remove_child(child)
		button_down.disconnect(remove_sprite)


func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		for item: UiTheme in theme_manager.themes:
			var theme_btn = UiThemeButton.new(item, %UI_Theme_Manager.current_theme == item)
			theme_btn.ach_man = ach_man
			add_child.call_deferred(theme_btn)


func _on_visibility_changed():
	$"../..".scroll_vertical = 0
