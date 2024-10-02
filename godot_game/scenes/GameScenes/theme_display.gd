extends GridContainer

const BTN_SIZE: Vector2 = Vector2(64, 64)
@export var theme_manager: Node

## Class that describes UI theme button.
class UiThemeButton extends Button:
	var ui_theme
	func _init(_ui_theme: UiTheme):
		self.custom_minimum_size = BTN_SIZE
		self.size = BTN_SIZE
		self.expand_icon = false
		self.ui_theme = _ui_theme
		self.text = _ui_theme.theme_name
		
		theme = load("res://themes/vcr_font.tres")
		
		var box = StyleBoxFlat.new()
		box.bg_color = ui_theme.screen_tint
		box.set_corner_radius_all(50)
		self.add_theme_constant_override("outline_size", 2)
		self.add_theme_stylebox_override("normal", box)
		self.add_theme_stylebox_override("hover", box)
		#self.add_theme_stylebox_override("pressed", box)
		self.add_theme_stylebox_override("disabled", box)
		self.add_theme_stylebox_override("focus", box)
		
		
		update_locked()

	## Action when button is pressed.
	func _pressed():
		var manager = find_parent("Game").find_child("UI_Theme_Manager")
		manager.set_theme(self.ui_theme)

	func update_locked():
		var unlocked_items = DataGlobals.load_metadata()['unlocked_themes']
		var uid = Helpers.uid_str(self.ui_theme)
		self.disabled = false if self.ui_theme.unlocked else not uid in unlocked_items
		#self.tooltip_text = ui_theme.hint if disabled else ""
		self.text = "?" if self.disabled else ""


func _ready():
	for item: UiTheme in theme_manager.themes:
		var theme_btn = UiThemeButton.new(item)
		add_child(theme_btn)


func update_buttons():
	propagate_call("update_locked")


func _on_visibility_changed():
	$"../..".scroll_vertical = 0
