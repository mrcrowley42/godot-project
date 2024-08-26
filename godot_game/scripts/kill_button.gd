extends Button
@onready var creature = %Creature
@export var amount: float = 300

func _on_button_down():
	%BtnClick.play()
	creature.dmg(amount, 'food')
