extends Button

@onready var creature = %Creature

func _on_button_down():
	creature.dmg(300, 'ap')
