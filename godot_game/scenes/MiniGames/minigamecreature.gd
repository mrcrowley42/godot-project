extends AnimatedSprite2D


func gen_preview():
	var creature = find_parent("Game").find_child("Creature")
	sprite_frames = creature.main_sprite.sprite_frames
	scale = Vector2(1, 1) if creature.life_stage == Creature.LifeStage.EGG else scale
	animation = "idle"
	play()
	update_cosmetics()

func update_cosmetics():
	for child in get_children():
		remove_child(child)
	var creature = find_parent("Game").find_child("Creature")
	var acc_man: AccessoryManager = creature.accessory_manager
	for cosmetic in acc_man.current_cosmetics:
		cosmetic = acc_man.unlockables_dict[cosmetic]
		var new_sprite = AnimatedSprite2D.new()
		new_sprite.sprite_frames = cosmetic.sprite
		new_sprite.name = cosmetic.name
		new_sprite.position = acc_man.position_dict[cosmetic].position * (1 / .225)
		new_sprite.scale = acc_man.position_dict[cosmetic].scale * Vector2(1.0, 1.0)
		add_child.call_deferred(new_sprite, true)

		# Should maintain sync with main sprite
		await frame_changed
		new_sprite.play()
