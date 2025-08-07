class_name Table
extends StaticBody2D
@onready var allow_place = false
var melds : Array = []

func _on_area_2d_body_entered(body: Player) -> void:
	body.set_at_table(true,self) # should I send Object.get_instance_id()???
	

func _on_area_2d_body_exited(body: Player) -> void:
	body.set_at_table(false)

func attempt_meld(cards : Array[Card]) -> bool:
	if (meld_check(cards)):
		melds.append(cards)
		return true
	else: 
		print("not a valid meld")
	return false

## checking if the hand contains a valid meld
func meld_check(cards : Array[Card]) -> bool:
	return check_run(cards) or check_set(cards)

## TODO test!!! -> needs to be 3 or more cards
func check_run(cards : Array[Card]) -> bool:
	var ranks = []
	var suit = cards[0].get_suit()
	
	for card in cards:
		if card.get_suit() != suit:
			return false
		ranks.append(card.get_rank())
	
	ranks.sort()
	
	for i in ranks.size() - 2:
		if (ranks[i] != ranks[i + 1] - 1):
			return false
	
	return true

## TODO test!!! 3 or 4 only?
func check_set(cards : Array[Card]) -> bool:
	var rank = cards[0].get_rank()
	
	for card in cards:
		if card.get_rank() != rank:
			return false
			
	return true
