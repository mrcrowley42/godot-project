extends Button

@onready var creature = %Creature

func _on_button_down():
	%BtnClick.play()
	creature.dmg(300, 'fun')
