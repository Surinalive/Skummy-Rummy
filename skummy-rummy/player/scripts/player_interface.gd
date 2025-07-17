extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

#Display cards
func display_hand(hand) -> void:
	for card in hand:
		$PlayerHand.add_child(card)
		card.connect("card_toggled", untoggle_rest)
	
func add_to_hand(card) -> void:
	$"..".add_to_hand(card)
	$PlayerHand.add_child(card)
	card.connect("card_toggled", untoggle_rest)
	
func display_drawn_card(card) -> void:
	$DrawnCard.add_child(card)
	cards_clickable()

func cards_clickable() -> void:
	for card in $PlayerHand.get_children(false):
		if card == $PlayerHand/ReferenceRect:
			continue
		card.set_clickable()

func cards_unclickable() -> void:
	for card in $PlayerHand.get_children(false):
		if card == $PlayerHand/ReferenceRect:
			continue
		card.set_unclickable()


func untoggle_rest(selected_card) -> void:
	for card in $PlayerHand.get_children(false):
		if card == $PlayerHand/ReferenceRect:
			continue
		if card != selected_card:
			card.unpress_button()

func _on_select_button_pressed() -> void:
	var selected_card = get_selected_card()
	var drawn_card = get_drawn_card()
	Globals.trade(drawn_card, selected_card)
	$"..".remove_from_hand(selected_card)
	$PlayerHand.remove_child(selected_card)
	$DrawnCard.remove_child(drawn_card)
	add_to_hand(drawn_card)
	$"..".set_movable(true)
	cards_unclickable()
	
func _on_reject_button_pressed() -> void:
	$DrawnCard.remove_child(get_drawn_card())
	$"..".set_movable(true)
	cards_unclickable()
	
func get_selected_card() -> Node:
	for card in $PlayerHand.get_children(false):
		if card == $PlayerHand/ReferenceRect:
			continue
		if card.is_selected():
			return card
	return null
	
func get_drawn_card() -> Node:
	for card in $DrawnCard.get_children(false):
		if card == $DrawnCard/ReferenceRect:
			continue
		else:
			return card
	return null
