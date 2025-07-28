extends CharacterBody2D

@export var speed = 300.0 # how fast the player will move (pixels/sec)
var hand = []
var movable = true
var screen_size #size of game window
@export var at_spawn = false
@export var at_table = false
@onready var game = $".."

@onready var table_area : StaticBody2D
@onready var spawn_area : StaticBody2D

signal hit # TODO NOTE adding this because I'm following the tutorial a bit Might be 
#useful with powerups and multiplayer

# TODO CAn we clean this up later???
func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(_delta):
	if movable:
		get_input()
		move_and_slide()

# used to check for single events....
func _input(event):
	if event.is_action_pressed("action"):
		if (at_table || at_spawn):
			set_movable(false)
			$PlayerInterface.cards_clickable()
			$PlayerInterface.buttons_visible(true)
			if at_spawn:
				$PlayerInterface.display_drawn_card(spawn_area.draw_card())


	

#? As soon as spawned in, get dealt and display hand in player_interface
func _ready() -> void:
	hide() #hides the player when the game starts
	screen_size = get_viewport_rect().size
	
	
# NOTE TODO Sets the players position at the start of the game...
func start(pos):
	position = pos
	hand = game.deal()
	$PlayerInterface.display_hand(hand)
	$CollisionShape2D.disabled = false
	show()

## Allow player movement
func set_movable(value):
	movable = value
	if (value):
		at_spawn = false
		at_table = false

## Return the player's current hand
func get_hand() -> Array:
	return hand

## Add card to player's hand
func add_to_hand(card) -> void:
	hand.append(card)

## Remove card from player's hand
func remove_from_hand(card) -> void:
	hand.erase(card)

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

## NOTE 
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

func trade(drawn_card, selected_card):
	game.trade(drawn_card, selected_card)

func attempt_meld(cards) -> bool:
	set_movable(true)
	if (table_area.attempt_meld(cards)):
		return true
	return false
