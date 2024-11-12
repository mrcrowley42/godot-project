class_name MemoryGameLogic extends MiniGameLogic

@onready var base_mem_card = preload("res://scripts/minigames/memory_match/memory_card.tscn")
@onready var card_grid: GridContainer = owner.find_child("CardGrid")

const COLUMNS = 5;
const ROWS = 4;

var can_interact: bool = true
var card_deck: Array[MemoryCard] = []
var card_a: MemoryCard = null
var card_b: MemoryCard = null


func start_normal_game():
	create_game_board()

func start_timed_game():
	create_game_board()

## spawn cards & setup card grid
func create_game_board():
	await get_tree().create_timer(.1).timeout
	#var deck: Array = Array(range(10)) + Array(range(10))
	var deck = [1, 1, 1, 1, 1, 1 ,1 ,1 ,1, 1,
				1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	deck.shuffle()
	
	var spawn_timers = [null]
	for inx in range(7):
		var t: Timer = Timer.new()
		t.one_shot = true
		t.autostart = true
		t.wait_time = .04 * (inx + 1)
		add_child(t)
		spawn_timers.append(t)
	
	# spawn cards
	var i = 0
	var on_row = 0
	for card_val in deck:
		var timer_inx = (i % COLUMNS) + on_row
		var card: MemoryCard = base_mem_card.instantiate()
		card_grid.add_child(card)
		card.init(self, card_val, spawn_timers[timer_inx])
		card_deck.append(card)
		i += 1
		@warning_ignore("integer_division")  # shut up
		on_row = i / COLUMNS
	
	# set spacing of the card grid
	var card_dim: Vector2 = card_deck[0].front.size
	var remainder: Vector2 = card_grid.size - Vector2(card_dim.x * COLUMNS, card_dim.y * ROWS)
	card_grid["theme_override_constants/h_separation"] = card_dim.x + remainder.x / (COLUMNS-1)
	card_grid["theme_override_constants/v_separation"] = card_dim.y + remainder.y / (ROWS-1)
	card_grid.columns = COLUMNS

func card_flipped(card: MemoryCard):
	print(card)
	card_b = card if card_a != null else null
	card_a = card if card_a == null else card_a
	
	# compare values
	if card_a && card_b:
		can_interact = false
		await get_tree().create_timer(.8).timeout
		if card_a.card_value != card_b.card_value:
			card_a.flip_card()
			card_b.flip_card()
		else:
			card_a.lock_card_in()
			card_b.lock_card_in()
		card_a = null; card_b = null;
	can_interact = true

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
