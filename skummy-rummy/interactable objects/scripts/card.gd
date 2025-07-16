extends Control

#NOTE potential bug, button is drawn behind parent atm

# Note: A, 1, 2, 3, 4, 5, 6, 7, 8, 9, J, Q, K ->
# 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12.
# Club, Diamond, Heart, Spade -> 0, 1, 2, 3
@onready var card_rank: int
@onready var card_suit: int
signal card_toggled(card)

func set_rank(rank: int) -> void:
	card_rank = rank
	$ColorRect/rank.text = str(rank)

func get_rank() -> int:
	return card_rank
	
func set_suit(suit: int) -> void:
	card_suit = suit
	var text

	match suit :
		0:
			text = "club"
		1: 
			text = "diamond"
		2:
			text = "heart"
		3: 
			text = "spade"
	
	$ColorRect/suit_top.text = text
	$ColorRect/suit_bottom.text = text
	
	
func get_suit() -> int:
	return card_suit;
	
func set_clickable() -> void:
	$Button.disabled = false

func set_unclickable() -> void:
	$Button.disabled = true
	
