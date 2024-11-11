class_name MemoryGameLogic extends MiniGameLogic

@onready var card_grid: GridContainer = owner.find_child("CardGrid")


func start_normal_game():
	create_game_board()

func start_timed_game():
	create_game_board()

func create_game_board():
	var deck: Array = Array(range(10)) + Array(range(10))
	deck.shuffle()
	
	for card_val in deck:
		var card: MemoryCard = MemoryCard.new()
		card.init(self, card_val)
		card_grid.add_child(card)

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
