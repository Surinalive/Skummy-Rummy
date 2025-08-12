class_name Table
extends StaticBody2D

@export var melds : Array = []

@onready var allow_place = false

### SIGNALS LOGIC

func _on_area_2d_body_entered(body: Player) -> void:
	body.set_at_table(true,self) # should I send Object.get_instance_id()???

func _on_area_2d_body_exited(body: Player) -> void:
	body.set_at_table(false)

### CARD LOGIC

func attempt_meld(cards : Array[Card]) -> bool:
	if (meld_check(cards)):
		melds.append(cards)
		return true
	else: 
		print("Not a valid meld. Sets must be of same rank. Runs must be of same
		suit and ")
	return false

# HELPER: checks if meld is valid
func meld_check(cards : Array[Card]) -> bool:
	if cards.size() < 3:
		print("melds must contain 3 or more cards")
		return false
	return check_run(cards) or check_set(cards)

# HELPER: checks if meld is a run
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

# HELPER: checks if meld is a set
func check_set(cards : Array[Card]) -> bool:
	var rank = cards[0].get_rank()
	
	for card in cards:
		if card.get_rank() != rank:
			return false
			
	return true
