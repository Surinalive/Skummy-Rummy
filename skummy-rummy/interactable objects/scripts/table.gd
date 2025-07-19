extends StaticBody2D
@onready var player 
@onready var allow_place = false
var melds = []

func _input(event: InputEvent) -> void:
	if allow_place and event.is_action_pressed("action"):
		player.attempt_meld()

func _on_area_2d_body_entered(body: Node2D) -> void:
	allow_place = true
	player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	allow_place = false
	player = null

# keep track of cards that are placed
func place_meld(cards : Array):
	melds.append(cards)
	allow_place = false
	print(melds)
