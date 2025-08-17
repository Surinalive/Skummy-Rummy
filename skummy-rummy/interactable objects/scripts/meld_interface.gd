extends CanvasLayer

# Does this really need to be a sub viewport????

@onready var meld_grid : GridContainer = $CardMarginContainer/MeldGrid
const CARD_IMAGE_PATH = "res://interactable objects/scenes/card_image.tscn"

func _ready() -> void:
	Server.melds_synchronized.connect(_on_melds_synchronized)

func display_melds() -> void:
	clear_melds()
	var melds = Server.melds.values()
	
	if melds.size() == 0:
		return
	
	var i = 0;
	
	for meld in melds:
		for card_data in meld:
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

func _on_button_pressed() -> void:
	pass # Replace with function body.


func _on_button_2_pressed() -> void:
	pass # Replace with function body.


func _on_button_3_pressed() -> void:
	pass # Replace with function body.


func _on_button_4_pressed() -> void:
	pass # Replace with function body.


func _on_button_5_pressed() -> void:
	pass # Replace with function body.


func _on_button_6_pressed() -> void:
	pass # Replace with function body.


func _on_button_7_pressed() -> void:
	pass # Replace with function body.


func _on_button_8_pressed() -> void:
	pass # Replace with function body.


func _on_button_9_pressed() -> void:
	pass # Replace with function body.
