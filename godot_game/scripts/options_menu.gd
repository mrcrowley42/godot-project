extends PanelContainer
@onready var credits = %CreditsMenu
@onready var main_menu = %MainOptMenu
@onready var settings_menu = %GameplayOptionsMenu
@onready var sound_menu = %SoundMenu
@onready var appearance_menu = %AppearanceMenu
@onready var facts_menu = %FactsMenu

enum Menu {CREDITS, SOUND, SETTINGS, FACTS, APPEARANCE}
@onready var menus = {Menu.CREDITS: credits, Menu.SOUND: sound_menu,
	Menu.SETTINGS: settings_menu, Menu.FACTS: facts_menu,
	Menu.APPEARANCE: appearance_menu }

var current_menu

func _ready():
	self.visible = false

func return_to_main():
	if current_menu != null:
		menus[current_menu].hide()
		current_menu = null
	main_menu.show()

func change_menu(new_menu: Menu):
	main_menu.hide()
	current_menu = new_menu
	menus[new_menu].show()

func _on_credits_btn_button_down():
	change_menu(Menu.CREDITS)

func _on_sound_btn_button_down():
	change_menu(Menu.SOUND)

func _on_visibility_changed():
	## DO WE WANT THIS?
	if current_menu != null:
		return_to_main()


func _on_gameplay_settings_btn_button_down():
	change_menu(Menu.SETTINGS)


func _on_appearance_btn_button_down():
	change_menu(Menu.APPEARANCE)


func _on_fact_btn_button_down():
	change_menu(Menu.FACTS)
