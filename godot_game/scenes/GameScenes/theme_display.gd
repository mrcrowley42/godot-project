extends GridContainer

const BTN_SIZE: Vector2 = Vector2(64, 64)
@export var theme_manager: Node

## Class that describes UI theme button.
class UiThemeButton extends Button:
	var ui_theme
	@warning_ignore("shadowed_variable")  # be quiet
	func _init(ui_theme: UiTheme):
		self.custom_minimum_size = BTN_SIZE
		self.size = BTN_SIZE
		self.expand_icon = false
		self.ui_theme = ui_theme
		self.text = ui_theme.theme_name
		#update_locked()

	## Action when button is pressed.
	func _pressed():
		var manager = find_parent("Game").find_child("UI_Theme_Manager")
		manager.set_theme(self.ui_theme)


	#func update_locked():
		#var unlocked_items = DataGlobals.load_metadata()['unlocked_cosmetics']
		#var uid = str(ResourceLoader.get_resource_uid(self.cosmetic.resource_path))
		#self.disabled = false if self.cosmetic.unlocked else not uid in unlocked_items
		#self.tooltip_text = cosmetic.hint if disabled else cosmetic.desc
		#self.text = "?" if self.disabled else ""
		#icon = null if self.disabled else cosmetic.thumbnail


func _ready():
	for item: UiTheme in theme_manager.themes:
		var theme_btn = UiThemeButton.new(item)
		add_child(theme_btn)


func update_buttons():
	propagate_call("update_locked")


func _on_visibility_changed():
	$"../..".scroll_vertical = 0
