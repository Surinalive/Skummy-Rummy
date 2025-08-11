class_name PlayerInterface
extends CanvasLayer

const CARD_SCENE_PATH = "res://interactable objects/scenes/card.tscn"

@onready var selected_cards : Array[Card]= []
@onready var player : Player = get_parent()
@onready var player_cards : Array[Card]= []
@export var player_hand : HBoxContainer

#TODO gettin rid of groups for now...

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttons_visible(false)

func buttons_visible(value) -> void:
	$SelectButton.visible = value
	$RejectButton.visible = value

func get_card_data(card : Card) -> Dictionary:
	var card_data = {
				"deck_id" : card.get_id(),
				"suit" : card.get_suit(),
				"rank" : card.get_rank()
			}
	
	return card_data

### Display cards dealt
func display_hand(hand : Array = player.card_data_hand) -> void:
	remove_displayed_cards()
	for card_data in hand:
		var card_scene = preload(CARD_SCENE_PATH)
		var card = card_scene.instantiate()
		card.set_id(card_data["deck_id"])
		card.set_suit(card_data["suit"])
		card.set_rank(card_data["rank"])
		player_cards.append(card)
		$PlayerHand.add_child(card)
		card.connect("card_selected", card_selected)
		card.connect("card_unselected", card_unselected)

## Display the drawn card for the player
func display_drawn_card(card_data : Dictionary) -> void:
	var card_scene = preload(CARD_SCENE_PATH)
	var card = card_scene.instantiate()
	card.set_suit(card_data["suit"])
	card.set_rank(card_data["rank"])
	
	$DrawnCard.add_child(card)
	cards_clickable()
	buttons_visible(true)

## Allows cards in hand to be selected
func cards_clickable() -> void:
	for card in player_cards:
		card.set_clickable()

## Disallows cards in hand to be selected
#TODO need to fix logic.... error
func cards_unclickable() -> void:
	for card in player_cards:
		card.set_unclickable()
		card.unpress_button()


func card_selected(card) -> void:
	if player.at_spawn:
		untoggle_rest(card)
		selected_cards = [card]
	if player.at_table:
		selected_cards.append(card)

#TODO quick fix for error....error with multiplayer
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
	
	if selected_cards.size() < 1:
		print("A card must be selected!")
		return
	
	# Double checking only one card is selected
	if selected_cards.size() > 1:
		print("More than one card is selected at the moment")
		return
	else:
		selected_card = selected_cards.get(0)
	
	var drawn_card : Card = get_drawn_card()
	
	# remove drawn card from deck and add selected card to deck
	player.trade(get_card_data(drawn_card), get_card_data(selected_card))
	# remove selected card from player interface & player hand
	selected_cards = []
	
	#remove drawn card from player interface and add to player hand
	$DrawnCard.remove_child(drawn_card)
	
	player.set_movable(true)
	cards_unclickable()
	buttons_visible(false)

#TODO
#on select button helper
func at_table_select() -> void:
	#Was attempted meld successful?
	if (player.attempt_meld(selected_cards)):
	#Remove cards from player hand and player interface
		for card in selected_cards:
			player.remove_from_hand(get_card_data(card))
	selected_cards = []
	cards_unclickable()
	buttons_visible(false)

# Removes the drawn card from the screen
func _on_reject_button_pressed() -> void:
	selected_cards = []
	$DrawnCard.remove_child(get_drawn_card())
	player.set_movable(true)
	cards_unclickable()
	buttons_visible(false)
	
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

func remove_displayed_cards() -> void:
	for card in $PlayerHand.get_children(false):
		if card != $PlayerHand/ReferenceRect:
			$PlayerHand.remove_child(card)
