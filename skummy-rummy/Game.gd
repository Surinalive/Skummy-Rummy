extends Node

@onready var deck_cards = []
const CARD_SCENE_PATH: String = "res://interactable objects/scenes/card.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_deck()
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# NOTE, need to add powerup cards functionality
# Generates our card deck!
func generate_deck() -> void:
	for i in 3:
		for j in 12:
			var card_scene = preload(CARD_SCENE_PATH)
			var card = card_scene.instantiate()
			card.set_suit(i + 1)
			card.set_rank(j + 1)
			deck_cards.append(card)

# Deals out and returns a "hand" of 7 cards
func deal() -> Array:
	var hand = []
	for i in 7:
		var card = deck_cards.pick_random()
		hand.append(card)
		#TODO: remember to add cards back to deck
		deck_cards.erase(card)
	return hand

# Draws a random card from the deck
func draw() -> Node:
	var card = deck_cards.pick_random()
	return card

# TODO: fix logic later. adds card back to deck...
# Replaces drawn card ^^ with card player selected to trade
func trade(drawn_card, player_card) -> void:
	deck_cards.append(player_card)
	deck_cards.erase(drawn_card)

# NOTE tutorial has this named game_over()... NOt suitable to our purposes
func _on_player_hit() -> void:
	pass # Replace with function body.

func new_game():
	$Player.start($P1StartPosition.position)
	$StartTimer.start()

#NOTE the tutorial had this start two other timers....
func _on_start_timer_timeout() -> void:
	pass # Replace with function body.
