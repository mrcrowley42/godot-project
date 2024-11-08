class_name MemoryGameLogic extends MiniGameLogic

var selected_cards: Array[Card] = []
var player_score: int = 0
var possible = Array(range(20))
var complete: bool = false


## Class that describes the cards (buttons) for memory.
class Card extends Button:
	var parent: MemoryGameLogic
	var value: int
	
	func _init(parent_node, card_value):
		self.parent = parent_node
		self.value = card_value
		self.theme = load("res://themes/action_btn.tres")
		self.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		self.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	func _pressed():
		print("pressed")
	
	func flip_card():
		print("flip")

#func create_deck() -> Array:
	#var deck: Array = []
	#for i in range(10):
		#for j in range(2):
			#var card = MemCard.new(str(possible[i]))
			#deck.append(card)
	#return deck
#
#func _ready():
	#var deck = create_deck()
	#deck.shuffle()
	#for card in deck:
		#%CardGrid.add_child(card)
#
#func choose_card(card):
	#if selected_cards.size() < 3:
		#selected_cards.append(card)
		#card.flip_card()
		#card.disabled = true
		#
	#if selected_cards.size() == 2:
		#if selected_cards[0].hidden_value == selected_cards[1].hidden_value:
			#player_score += 1
			#for item in selected_cards:
				#item.text = "X"
				#item.disabled = true
			#%SFX.play_sound("correct")
		#else:
			#await get_tree().create_timer(.45).timeout
			#for item in selected_cards:
				#item.flip_card()
				#item.disabled = false
			#%SFX.play_sound("wrong")
			#
		#selected_cards.clear()
