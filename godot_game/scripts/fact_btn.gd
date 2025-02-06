class_name FactBtn extends Button

var fact: Fact
var num: int

func update_locked(new_fact_uid = null):
	var uid = Helpers.uid_str(fact)
	if new_fact_uid != null and new_fact_uid == uid:
		self.text = str(num)
		var sprite: Sprite2D = Globals.spawn_exclamation_point(self)
		button_down.connect(remove_sprite.bind(sprite))

func remove_sprite(child):
	remove_child(child)
	button_down.disconnect(remove_sprite)
