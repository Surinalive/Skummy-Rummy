class_name Player
extends CharacterBody2D

@export var speed = 300.0 # how fast the player will move (pixels/sec)
@export var at_spawn = false
@export var at_table = false

var card_data_hand : Array[Dictionary] = []
var movable = true #TODO not process
var screen_size #size of game window

@onready var game : Game #TODO get rid of
@onready var camera = $Camera2D as Camera2D
@onready var table_area : StaticBody2D
@onready var spawn_area : StaticBody2D

#signal hit # TODO NOTE adding this because I'm following the tutorial a bit Might be 
#useful with powerups and multiplayer

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect signals
	Server.hands_synchronized.connect(_on_hands_synchronized)
	
	# Get screen_size and set camera
	screen_size = get_viewport_rect().size #NOTE: do we still need this?
	if is_multiplayer_authority(): 
		camera.make_current()
	
	# Gets player hand and displays it
	var my_id = multiplayer.get_unique_id()
	
	if Server.player_hands.has(my_id):
		card_data_hand = Server.player_hands[my_id]
	
	if is_multiplayer_authority():
		$PlayerInterface.display_hand(card_data_hand)

func _physics_process(_delta):
	if !is_multiplayer_authority():
		return
	
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	move_and_slide()

# used to check for single events....
func _input(event):
	if !is_multiplayer_authority():
		return
	
	if event.is_action_pressed("action"):
		
		if (at_table):
			set_physics_process(false)
			$PlayerInterface.cards_clickable()
			$PlayerInterface.buttons_visible(true)
			meld_interface_visible(true)

		if at_spawn:
			$PlayerInterface.display_drawn_card(spawn_area.draw_card())

### SETTERS

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

### GETTERS

func get_hand() -> Array[Dictionary]:
	return card_data_hand

### SIGNALS LOGIC

func _on_hands_synchronized():
	var my_id = multiplayer.get_unique_id()
	
	if Server.player_hands.has(my_id):
		card_data_hand = Server.player_hands[my_id]
	
	$PlayerInterface.display_hand(card_data_hand)

### CARD LOGIC

func remove_card_from_hand(card_data : Dictionary) -> void:
	#Server.remove_from_player_hand.rpc(card_data)
	if multiplayer.is_server():
		Server.server_remove_from_player_hand(card_data)
	else:
		Server.rpc_id(1, "remove_from_player_hand", card_data)#TODO


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

func trade(drawn_card : Dictionary, selected_card : Dictionary):
	#Server.rpc_id(1, "trade", drawn_card, selected_card)
	if multiplayer.is_server():
		Server.server_trade(drawn_card, selected_card)
	else:
		Server.rpc_id(1, "trade", drawn_card, selected_card)

func attempt_meld(card_datas : Array[Dictionary]) -> void:
	if multiplayer.is_server():
		Server.attempt_server_meld(card_datas)
	else:
		Server.rpc_id(1, "attempt_player_meld", card_datas)

func hit(player_id : int, meld : Array[Dictionary], selected_cards : Array[Dictionary]):
	if multiplayer.is_server():
		Server.server_hit(player_id, meld, selected_cards)
	else:
		Server.rpc_id(1, "player_hit", player_id, meld, selected_cards)
	
	meld_interface_visible(false)

### MISC
func hide_interface() -> void:
	$PlayerInterface.visible = false

func meld_interface_visible(value : bool) -> void:
	if value:
		$Melds.visible = true
		$Melds.display_melds()
	else:
		$Melds.visible = false
