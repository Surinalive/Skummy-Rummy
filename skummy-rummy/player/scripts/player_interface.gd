extends CanvasLayer

@onready var selected_cards = []
@onready var player = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttons_visible(false)

func buttons_visible(value) -> void:
	$SelectButton.visible = value
	$RejectButton.visible = value
	
## Display cards dealt
func display_hand(hand) -> void:
	for card in hand:
		$PlayerHand.add_child(card)
		card.add_to_group("cards")
		card.connect("card_selected", card_selected)
		card.connect("card_unselected", card_unselected)

## Add a card to the player's hand
func add_to_hand(card) -> void:
	player.add_to_hand(card)
	$PlayerHand.add_child(card)
	card.add_to_group("cards")
	#connect signals
	card.connect("card_selected", card_selected)
	card.connect("card_unselected", card_unselected)

## Remove a card from player"s hand
func remove_from_hand(card) -> void:
	card.remove_from_group("cards")
	# remove card from player interface
	$PlayerHand.remove_child(card)
	# remove selected card from player hand
	player.remove_from_hand(card)

## Display the drawn card for the player
func display_drawn_card(card) -> void:
	$DrawnCard.add_child(card)
	cards_clickable()
	buttons_visible(true)

## Allows cards in hand to be selected
func cards_clickable() -> void:
	get_tree().call_group("cards", "set_clickable")

## Disallows cards in hand to be selected
#TODO need to fix logic.... error
func cards_unclickable() -> void:
	get_tree().call_group("cards", "set_unclickable")
	get_tree().call_group("cards", "unpress_button")

func card_selected(card) -> void:
	if player.at_spawn:
		untoggle_rest(card)
		selected_cards = [card]
	if player.at_table:
		selected_cards.append(card)

#TODO quick fix for error....
func card_unselected(card) -> void:
	var selected_card = selected_cards.find(card)
	if (selected_card > -1):
		selected_cards.remove_at(selected_card)

# When player selects a card in hand, others are unselected 
#TODO can probably clean this up / refactor
func untoggle_rest(selected_card) -> void:
	for card in $PlayerHand.get_children(false):
		if card != $PlayerHand/ReferenceRect:
			if card != selected_card:
				card.unpress_button()

# Adds drawn_card to hand and puts selected card back in deck
func _on_select_button_pressed() -> void:
	if selected_cards.size() < 1:
		return
	if player.at_spawn:
		at_spawn_select()
	else:
		at_table_select()

# on select button helper
func at_spawn_select() -> void:
	var selected_card
	# Double checking only one card is selected
	if selected_cards.size() > 1:
		print("More than one card is selected at the moment")
		return
	else:
		selected_card = selected_cards.get(0)
	
	var drawn_card = get_drawn_card()
	# remove drawn card from deck and add selected card to deck
	player.trade(drawn_card, selected_card)
	# remove selected card from player interface & player hand
	remove_from_hand(selected_card)
	selected_cards = []
	
	#remove drawn card from player interface and add to player hand
	$DrawnCard.remove_child(drawn_card)
	add_to_hand(drawn_card)
	
	player.set_movable(true)
	cards_unclickable()
	buttons_visible(false)

#on select button helper
func at_table_select() -> void:
	#Was attempted meld successful?
	if (player.attempt_meld(selected_cards)):
	#Remove cards from player hand and player interface
		for card in selected_cards:
			remove_from_hand(card)
	selected_cards = []
	cards_unclickable()
	buttons_visible(false)

# Removes the drawn card from the screen
func _on_reject_button_pressed() -> void:
	selected_cards = []
	$DrawnCard.remove_child(get_drawn_card())
	player.set_movable(true)
	cards_unclickable()
	
## Retrieve drawn card
func get_drawn_card() -> Node:
	for card in $DrawnCard.get_children(false):
		if card != $DrawnCard/ReferenceRect:
			return card
	return null

func get_selected_card() -> Node:
	for card in $PlayerHand.get_children(false):
		if card != $PlayerHand/ReferenceRect:
			if card.is_selected():
				return card
	return null
