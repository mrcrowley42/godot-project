class_name CreaturePreview extends AnimatedSprite2D

func _notification(noti: int) -> void:
	if noti == Globals.NOTIFICATION_CREATURE_ACCESSORIES_ARE_LOADED:
		sprite_frames = %Creature.creature.sprite_frames
		position = sprite_frames.get_frame_texture("idle", 0).get_size() * scale * .5
		animation = "idle"
		play()
		update_cosmetics()

func update_cosmetics():
	for child in get_children():
		remove_child(child)
	
	var acc_man: AccessoryManager = %Creature.accessory_manager
	for cosmetic in acc_man.current_cosmetics:
		cosmetic = acc_man.unlockables_dict[cosmetic]
		var new_sprite = AnimatedSprite2D.new()
		new_sprite.sprite_frames = cosmetic.sprite
		new_sprite.name = cosmetic.name
		new_sprite.position = acc_man.position_dict[cosmetic] * (1 / .225)
		add_child.call_deferred(new_sprite, true)
		
		# Should maintain sync with main sprite
		await frame_changed
		new_sprite.play()


func _on_cosmetic_items_cosmetic_btn_pressed() -> void:
	update_cosmetics()