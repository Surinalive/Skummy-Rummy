class_name MeldContainer
extends HBoxContainer

@onready var player_id
@onready var meld
#Do I need to store the meld?
#refactor
func set_player_id(id):
	player_id = id
	
func set_meld(card_datas):
	meld = card_datas

func get_player_id():
	return player_id

func get_meld():
	return meld
