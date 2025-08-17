class_name CardImage
extends TextureRect

var card_data : Dictionary

func set_card_data(new_card_data : Dictionary) -> void:
	self.card_data = new_card_data

func get_card_data() -> Dictionary:
	return card_data

func set_icon():
	$".".show()
	var suit = card_data["suit"]
	var rank = card_data["rank"]
	var texture_path
	
	match suit :
		1:
			texture_path = "res://art/cards-png/Clubs/Clubs_card_"
		2: 
			texture_path = "res://art/cards-png/Diamonds/Diamonds_card_"
		3:
			texture_path = "res://art/cards-png/Hearts/Hearts_card_"
		4: 
			texture_path = "res://art/cards-png/Spades/Spades_card_"

	texture_path  = texture_path + str(rank) + ".png"
	
	$".".texture = load(texture_path)

func reset_icon():
	$".".texture = null
	$".".hide()
