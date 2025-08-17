class_name PlayerInterface
extends CanvasLayer

@export var player_hand : HBoxContainer

const CARD_SCENE_PATH = "res://interactable objects/scenes/card.tscn"

@onready var selected_cards : Array[Dictionary]= []
@onready var player : Player = get_parent()
@onready var player_cards : Array[Card]= []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttons_visible(false)

func buttons_visible(value : bool) -> void:
	$SelectButton.visible = value
	$RejectButton.visible = value

## Display cards dealt
func display_hand(hand : Array = player.card_data_hand) -> void:
	remove_displayed_cards()
	
	# Load each card with given data
	for card_data in hand:
		var card_scene = preload(CARD_SCENE_PATH)
		var card = card_scene.instantiate()
		card.set_id(card_data["deck_id"])
		card.set_suit(card_data["suit"])
		card.set_rank(card_data["rank"])
		card.set_icon()
		player_cards.append(card)
		$PlayerHand.add_child(card)
		card.connect("card_selected", _on_card_selected)
		card.connect("card_unselected", _on_card_unselected)

# HELPER
func remove_displayed_cards() -> void:
	for card in $PlayerHand.get_children(false):
		$PlayerHand.remove_child(card)

## Display the drawn card for the player
func display_drawn_card(card_data) -> void:
	if card_data == null:
		return
	
	player.set_physics_process(false)
	cards_clickable()
	buttons_visible(true)
	
	# Load card_image from data given
	$DrawnCard/CardImage.set_card_data(card_data)
	$DrawnCard/CardImage.set_icon()

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

### SIGNAL LOGIC

func _on_select_button_pressed() -> void:
	if selected_cards.size() < 1:
		return
	if player.at_spawn:
		at_spawn_select()
	else:
		player.attempt_meld(selected_cards)
		reset()

# HELPER
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
	
	# Remove drawn card from deck and add selected card to deck
	player.trade($DrawnCard/CardImage.get_card_data(), selected_card)
	
	reset()

# HELPER
func get_card_data(card : Card) -> Dictionary:
	var card_data = {
				"deck_id" : card.get_id(),
				"suit" : card.get_suit(),
				"rank" : card.get_rank()
			}
	return card_data

func _on_reject_button_pressed() -> void:
	reset()

func _on_card_selected(card : Card) -> void:
	if player.at_spawn:
		untoggle_rest(card)
		selected_cards = [get_card_data(card)]
	if player.at_table:
		selected_cards.append(get_card_data(card))

# HELPER: When player selects a card in hand, others are unselected at spawn
func untoggle_rest(selected_card : Card) -> void:
	for card in $PlayerHand.get_children(false):
		if card != selected_card:
			card.unpress_button()

#TODO quick fix for error....error with multiplayer
func _on_card_unselected(card : Card) -> void:
	var selected_card_index = selected_cards.find(get_card_data(card))
	if (selected_card_index > -1):
		selected_cards.remove_at(selected_card_index)

# HELPER
func get_selected_card() -> Node:
	for card in $PlayerHand.get_children(false):
		if card.is_selected():
			return card
	return null

# HELPER
func reset() -> void:
	# Removes the drawn card from the screen
	$DrawnCard/CardImage.reset_icon()
	player.meld_interface_visible(false)
	
	# Resets player interface
	selected_cards = []
	cards_unclickable()
	buttons_visible(false)
	
	# Allows player movement
	player.set_physics_process(true)
	player.set_at_spawn(false)
	player.set_at_table(false)
