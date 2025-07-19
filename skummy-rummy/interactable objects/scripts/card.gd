extends Control

#NOTE potential bug, button is drawn behind parent atm

# Note: A, 1, 2, 3, 4, 5, 6, 7, 8, 9, J, Q, K ->
# 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12.
# Club, Diamond, Heart, Spade -> 1, 2, 3, 4
@onready var card_rank: int
@onready var card_suit: int
@onready var selected = false
signal card_selected(card)
signal card_unselected(card)

func set_rank(rank: int) -> void:
	card_rank = rank
	$ColorRect/rank.text = str(rank)

func get_rank() -> int:
	return card_rank

func set_suit(suit: int) -> void:
	card_suit = suit
	var text

	match suit :
		1:
			text = "club"
		2: 
			text = "diamond"
		3:
			text = "heart"
		4: 
			text = "spade"
	
	$ColorRect/suit_top.text = text
	$ColorRect/suit_bottom.text = text
	
func get_suit() -> int:
	return card_suit;

func set_clickable() -> void:
	$Button.disabled = false

func set_unclickable() -> void:
	$Button.disabled = true
	$ColorRect.color = Color(1, 1, 1, 1)
	
func is_selected() -> bool: 
	return selected

func unpress_button() -> void:
	$Button.set_pressed(false)
	selected = false
	$ColorRect.color = Color(1, 1, 1, 1)

func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		selected = true
		$ColorRect.color = Color(0, 1, 1, 1)
		card_selected.emit(self)
	else:
		selected = false
		$ColorRect.color = Color(1, 1, 1, 1)
		card_unselected.emit(self)
