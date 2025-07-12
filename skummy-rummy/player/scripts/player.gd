extends CharacterBody2D

const SPEED = 300.0
var hand = []
var movable = true
#signal table_click_go

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * SPEED
	

func _ready() -> void:
	hand = Globals.deal()
	$PlayerInterface.display_hand(hand)


func _physics_process(_delta):
	if movable:
		get_input()
		move_and_slide()
	
func display_card_drawn(card):
	movable = false
	$PlayerInterface.display_drawn_card(card)

func set_movable(value):
	movable = value

func get_hand() -> Array:
	return hand

func add_to_hand(card) -> void:
	hand.append(card)

func remove_from_hand(card) -> void:
	hand.erase(card)
