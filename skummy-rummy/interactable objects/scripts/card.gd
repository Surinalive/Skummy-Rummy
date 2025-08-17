class_name Card
extends Control

#NOTE potential bug, button is drawn behind parent atm

# Note: A, 1, 2, 3, 4, 5, 6, 7, 8, 9, J, Q, K ->
# 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12.
# Club, Diamond, Heart, Spade -> 1, 2, 3, 4
@onready var card_id: int
@onready var card_rank: int
@onready var card_suit: int
@onready var selected = false
@onready var texture : String

signal card_selected(card)
signal card_unselected(card)

### SETTERS

func set_id(id: int) -> void:
	card_id = id

func set_rank(rank: int) -> void:
	card_rank = rank

func set_suit(suit: int) -> void:
	card_suit = suit

	match suit :
		1:
			texture = "res://art/cards-png/Clubs/Clubs_card_"
		2: 
			texture = "res://art/cards-png/Diamonds/Diamonds_card_"
		3:
			texture = "res://art/cards-png/Hearts/Hearts_card_"
		4: 
			texture = "res://art/cards-png/Spades/Spades_card_"

func set_icon() -> void:
	var path  = texture + str(card_rank) + ".png"
	$".".icon = load(path)

func set_clickable() -> void:
	self.disabled = false

func set_unclickable() -> void:
	self.disabled = true

### GETTERS

func get_rank() -> int:
	return card_rank

func get_id() -> int:
	return card_id

func get_suit() -> int:
	return card_suit;

### SIGNAL LOGIC

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		selected = true
		card_selected.emit(self)
	else:
		selected = false
		card_unselected.emit(self)
		

### MISC

func is_selected() -> bool: 
	return selected

func unpress_button() -> void:
	self.button_pressed = false
	selected = false
