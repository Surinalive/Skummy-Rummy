extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttons_visible(false)

func buttons_visible(value) -> void:
	$SelectButton.visible = value
	$RejectButton.visible = value
	
# Display cards dealt
func display_hand(hand) -> void:
	for card in hand:
		$PlayerHand.add_child(card)
		card.connect("card_toggled", untoggle_rest)

# Add a card to the player's hand
func add_to_hand(card) -> void:
	$"..".add_to_hand(card)
	$PlayerHand.add_child(card)
	card.connect("card_toggled", untoggle_rest)

# Display the drawn card for the player
func display_drawn_card(card) -> void:
	$DrawnCard.add_child(card)
	cards_clickable()
	buttons_visible(true)

# Allows cards in hand to be selected
func cards_clickable() -> void:
	for card in $PlayerHand.get_children(false):
		if card == $PlayerHand/ReferenceRect:
			continue
		card.set_clickable()

# Disallows cards in hand to be selected
func cards_unclickable() -> void:
	for card in $PlayerHand.get_children(false):
		if card == $PlayerHand/ReferenceRect:
			continue
		card.set_unclickable()

# When player selects a card in hand, others are unselected 
#TODO can probably clean this up / refactor
func untoggle_rest(selected_card) -> void:
	for card in $PlayerHand.get_children(false):
		if card == $PlayerHand/ReferenceRect:
			continue
		if card != selected_card:
			card.unpress_button()

# Adds drawn_card to hand and puts selected card back in deck
# TODO adequate testing needed... Maybe on a smaller deck?
func _on_select_button_pressed() -> void:
	if $"..".at_spawn:
		at_spawn_select()
	else:
		at_table_select()
		
func at_spawn_select() -> void:
	var selected_card = get_selected_card()
	var drawn_card = get_drawn_card()
	$"..".trade(drawn_card, selected_card)
	$"..".remove_from_hand(selected_card)
	$PlayerHand.remove_child(selected_card)
	$DrawnCard.remove_child(drawn_card)
	add_to_hand(drawn_card)
	$"..".set_movable(true)
	cards_unclickable()
	buttons_visible(false)
	
func at_table_select() -> void:
	pass
	
# Removes the drawn card from the screen
func _on_reject_button_pressed() -> void:
	$DrawnCard.remove_child(get_drawn_card())
	$"..".set_movable(true)
	cards_unclickable()

# Retrieve selected card
func get_selected_card() -> Node:
	for card in $PlayerHand.get_children(false):
		if card == $PlayerHand/ReferenceRect:
			continue
		if card.is_selected():
			return card
	return null
	
# Retrieve drawn card
func get_drawn_card() -> Node:
	for card in $DrawnCard.get_children(false):
		if card == $DrawnCard/ReferenceRect:
			continue
		else:
			return card
	return null
