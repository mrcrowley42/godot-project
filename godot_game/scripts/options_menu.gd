extends PanelContainer

@export var cosmenits_btn: Button

@onready var credits = %CreditsMenu
@onready var main_menu = %MainOptMenu
@onready var theme_menu = %ThemeMenu
@onready var settings_menu = %SettingsMenu
@onready var cosmetics_menu = %CosmeticsMenu
@onready var facts_menu = %FactsMenu
@onready var ambience_menu = %AmbienceMenu
@onready var creatures_menu = %CreaturesMenu
@onready var achievement_menu = %AchievementMenu
@onready var creature: Creature = %Creature

enum Menu {CREDITS, SETTINGS, THEME, FACTS, APPEARANCE, AMBIENCE, CREATURES, ACHIEVEMENTS}
@onready var menus = {Menu.CREDITS: credits, Menu.SETTINGS: settings_menu,
	Menu.THEME: theme_menu, Menu.FACTS: facts_menu,
	Menu.APPEARANCE: cosmetics_menu, Menu.AMBIENCE: ambience_menu,
	Menu.CREATURES: creatures_menu, Menu.ACHIEVEMENTS: achievement_menu}

var current_menu

func _ready():
	self.visible = false

func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_CREATURE_IS_LOADED:
		if creature.life_stage == Creature.LifeStage.EGG:
			cosmenits_btn.disabled = true

func return_to_main():
	if current_menu != null:
		menus[current_menu].hide()
		current_menu = null
	main_menu.show()

func return_to_settings():
	return_to_main()
	change_menu(Menu.SETTINGS)

func change_menu(new_menu: Menu):
	main_menu.hide()
	current_menu = new_menu
	menus[new_menu].show()

func _on_visibility_changed():
	## DO WE WANT THIS?
	if current_menu != null:
		return_to_main()

func _on_credits_btn_button_down():
	%BtnClick.play()
	change_menu(Menu.CREDITS)

func _on_settings_btn_button_down():
	%BtnClick.play()
	change_menu(Menu.SETTINGS)

func _on_theme_btn_button_down():
	%BtnClick.play()
	change_menu(Menu.THEME)

func _on_appearance_btn_button_down():
	%BtnClick.play()
	change_menu(Menu.APPEARANCE)

func _on_fact_btn_button_down():
	%BtnClick.play()
	change_menu(Menu.FACTS)

func _on_ambience_btn_button_down():
	%BtnClick.play()
	change_menu(Menu.AMBIENCE)

func _on_creatures_btn_button_down():
	%BtnClick.play()
	change_menu(Menu.CREATURES)

func _on_achievements_btn_button_down() -> void:
	%BtnClick.play()
	change_menu(Menu.ACHIEVEMENTS)
