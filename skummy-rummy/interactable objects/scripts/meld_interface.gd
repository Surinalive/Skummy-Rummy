extends CanvasLayer


#TODO refactoe

@onready var meld_grid : GridContainer = $CardMarginContainer/MeldGrid
const CARD_IMAGE_PATH = "res://interactable objects/scenes/card_image.tscn"

signal hit_check(player_id, meld)


func _ready() -> void:
	Server.melds_synchronized.connect(_on_melds_synchronized)

func display_melds() -> void:
	clear_melds()
	var melds = Server.melds
	
	
	if melds.size() == 0:
		return
	
	var i = 0;
	# TODO change code to add a meld container with each meld instead
	for player_id in melds:
		var meld_container : MeldContainer = meld_grid.get_child(i)
		meld_container.set_player_id(player_id)
		meld_container.set_meld(melds[player_id])
		
		for card_data in melds[player_id]:
			var card_image_path = preload(CARD_IMAGE_PATH)
			var card_image : CardImage = card_image_path.instantiate()
			card_image.set_card_data(card_data)
			card_image.set_icon()
			var child = meld_grid.get_child(i)
			child.add_child(card_image)
		i = i + 1

func _on_melds_synchronized() -> void:
	display_melds()

func clear_melds() -> void:
	for HBox in meld_grid.get_children(false):
		for image : CardImage in HBox.get_children(false):
			image.queue_free()

#fix button signal handlers name...

func _on_button_0_pressed() -> void:
	# need Server to check if added the card creates a proper meld...
	var meld_container : MeldContainer = meld_grid.get_child(0)

	hit_check.emit(meld_container.get_player_id(), meld_container.get_meld())
	

func _on_button_2_pressed() -> void:
	var meld_container : MeldContainer = meld_grid.get_child(1)
	
	hit_check.emit(meld_container.get_player_id(), meld_container.get_meld())
	

func _on_button_3_pressed() -> void:
	var meld_container : MeldContainer = meld_grid.get_child(2)
	
	hit_check.emit(meld_container.get_player_id(), meld_container.get_meld())
	

func _on_button_4_pressed() -> void:
	var meld_container : MeldContainer = meld_grid.get_child(3)
	
	hit_check.emit(meld_container.get_player_id(), meld_container.get_meld())
	

func _on_button_5_pressed() -> void:
	var meld_container : MeldContainer = meld_grid.get_child(4)
	
	hit_check.emit(meld_container.get_player_id(), meld_container.get_meld())
	

func _on_button_6_pressed() -> void:
	var meld_container : MeldContainer = meld_grid.get_child(5)
	
	hit_check.emit(meld_container.get_player_id(), meld_container.get_meld())
	

func _on_button_7_pressed() -> void:
	var meld_container : MeldContainer = meld_grid.get_child(6)
	
	hit_check.emit(meld_container.get_player_id(), meld_container.get_meld())
	

func _on_button_8_pressed() -> void:
	var meld_container : MeldContainer = meld_grid.get_child(7)
	
	hit_check.emit(meld_container.get_player_id(), meld_container.get_meld())
	

func _on_button_9_pressed() -> void:
	var meld_container : MeldContainer = meld_grid.get_child(8)
	
	hit_check.emit(meld_container.get_player_id(), meld_container.get_meld())
	
