class_name Player
extends CharacterBody2D

@export var speed = 300.0 # how fast the player will move (pixels/sec)
var card_data_hand : Array[Dictionary] = []
var movable = true
var screen_size #size of game window

@export var at_spawn = false
@export var at_table = false
@onready var game : Game
@onready var camera = $Camera2D as Camera2D
@onready var table_area : StaticBody2D
@onready var spawn_area : StaticBody2D

signal hit # TODO NOTE adding this because I'm following the tutorial a bit Might be 
#useful with powerups and multiplayer

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

#? As soon as spawned in, get dealt and display hand in player_interface
func _ready() -> void:
	#hide() #hides the player when the game starts
	Server.hands_synchronized.connect(_on_hands_synchronized)
	screen_size = get_viewport_rect().size
	if is_multiplayer_authority(): camera.make_current()
	
	$CollisionShape2D.disabled = false   


func _physics_process(_delta):
	if !is_multiplayer_authority():
		return
		
	if movable:
		var input_direction = Input.get_vector("left", "right", "up", "down")
		velocity = input_direction * speed
		move_and_slide()

# used to check for single events....
func _input(event):
	if !is_multiplayer_authority():
		return
	
	if event.is_action_pressed("action"):
		print("ACTION pressed. Calling cards_clickable().")
		if (at_table || at_spawn):
			set_movable(false)
			$PlayerInterface.cards_clickable()
			$PlayerInterface.buttons_visible(true)
			if at_spawn:
				$PlayerInterface.display_drawn_card(spawn_area.draw_card())

func _on_hands_synchronized():
	# This function is now guaranteed to run AFTER the hands have been updated.
	var my_id = multiplayer.get_unique_id()
	
	if Server.player_hands.has(my_id):
		card_data_hand = Server.player_hands[my_id]
	
	## Now, it is safe to display the hand.
	#$PlayerInterface.display_hand(card_data_hand)

# NOTE TODO Sets the players position at the start of the game...
func start(pos):
	position = pos
	#show()

## Allow player movement
func set_movable(value):
	movable = value
	if (value):
		at_spawn = false
		at_table = false

## Return the player's current hand
func get_hand() -> Array[Dictionary]:
	return card_data_hand

## Remove card to player's hand
func remove_from_hand(card_data : Dictionary) -> void:
	#Server.remove_from_player_hand.rpc(card_data)
	Server.rpc_id(1, "remove_from_player_hand", card_data)


# NOTE
# Got this from the tutorial... Wonder if it will be better for when we have 
# animated sprites
#func _process(delta):
	#var velocity = Vector2.ZERO # The player's movement vector.
	#if Input.is_action_pressed("right"):
		#velocity.x += 1
	#if Input.is_action_pressed("left"):
		#velocity.x -= 1
	#if Input.is_action_pressed("down"):
		#velocity.y += 1
	#if Input.is_action_pressed("up"):
		#velocity.y -= 1
#
	#if velocity.length() > 0:
		#velocity = velocity.normalized() * speed
		##$AnimatedSprite2D.play()
	##else:
		##$AnimatedSprite2D.stop()
	#position += velocity * delta
	#position = position.clamp(Vector2.ZERO, screen_size)

# NOTE 
##func _on_body_entered(_body):
	##hide() # Player disappears after being hit.
	##hit.emit()
	### Must be deferred as we can't change physics properties on a physics callback.
	## This tells godot to disable collision shape when safe (set_deferred) so that the 
	## his signal isn't repeatedly sent
	##$CollisionShape2D.set_deferred("disabled", true)

func set_at_spawn(bool_value, spawner: StaticBody2D = null) -> void:
	if bool_value:
		at_spawn = bool_value
		spawn_area = spawner
	else:
		at_spawn = bool_value
		spawn_area = null

func set_at_table(bool_value, table : StaticBody2D = null) -> void:
	if bool_value:
		at_table = bool_value
		table_area = table
	else:
		at_table = bool_value
		table_area = null

func trade(drawn_card : Dictionary, selected_card : Dictionary):
	Server.rpc_id(1, "trade", drawn_card, selected_card)

func attempt_meld(cards : Array[Card]) -> bool:
	set_movable(true)
	if (table_area.attempt_meld(cards)):
		return true
	return false
