class_name MemoryGameLogic extends MiniGameLogic

@onready var base_mem_card = preload("res://scripts/minigames/memory_match/memory_card.tscn")
@onready var card_grid: GridContainer = owner.find_child("CardGrid")
@onready var score_label: Label = owner.find_child("ScoreLabel")

const COLUMNS = 5;
const ROWS = 4;

const SCORE_LABEL_TEXT = {
	null: "-\n\n-",
	true: "Time\n\n%.1f",
	false: "Guesses\n\n%.0f"
}

var can_interact: bool = true
var card_deck: Array[MemoryCard] = []
var card_a: MemoryCard = null
var card_b: MemoryCard = null

var is_timed_game: bool = false

var card_pairs_completed: int = 0
var guesses_count: int = 0
var game_time: float = 0.
var game_start_time: float = 0.


func start_normal_game():
	guesses_count = 0
	is_timed_game = false
	create_game_board()
	update_score_label()

func start_timed_game():
	game_time = 0.
	is_timed_game = true
	create_game_board()
	update_score_label()

## spawn cards & setup card grid
func create_game_board():
	await get_tree().create_timer(.15).timeout
	var deck: Array = Array(range(10)) + Array(range(10))
	#var deck = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
				#1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
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
	# start timer!
	if game_start_time == 0.:
		game_start_time = Time.get_unix_time_from_system()
	
	card_b = card if card_a != null else null
	card_a = card if card_a == null else card_a
	
	# compare values
	if card_a && card_b:
		await get_tree().create_timer(.8).timeout
		
		guesses_count += 1
		if card_a.card_value != card_b.card_value:
			card_a.flip_card()
			card_b.flip_card()
		else:
			card_pairs_completed += 1
			card_a.lock_card_in()
			card_b.lock_card_in()
		
		if !is_timed_game:
			update_score_label()
		card_a = null; card_b = null;
		
		if card_pairs_completed == 10:
			finish_game()

func update_score_label():
	var score = game_time if is_timed_game else float(guesses_count)
	score_label.text = SCORE_LABEL_TEXT[is_timed_game] % score

func _process(_delta: float) -> void:
	if is_timed_game && game_start_time > 0.:
		game_time = Time.get_unix_time_from_system() - game_start_time
		update_score_label()

func finish_game():
	pass

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
