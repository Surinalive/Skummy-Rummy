extends CharacterBody2D

@export var speed = 300.0 # how fast the player will move (pixels/sec)
var hand = []
var movable = true
var screen_size #size of game window
@export var at_spawn = false
@export var at_table = false

#signal table_click_go
signal hit # TODO NOTE adding this because I'm following the tutorial a bit Might be 
#useful with powerups and multiplayer

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(_delta):
	if movable:
		get_input()
		move_and_slide()

# As soon as spawned in, get dealt and display hand in player_interface
func _ready() -> void:
	hide() #hides the player when the game starts
	screen_size = get_viewport_rect().size

# NOTE TODO Sets the players position at the start of the game...
func start(pos):
	position = pos
	hand = $"..".deal()
	$PlayerInterface.display_hand(hand)
	$CollisionShape2D.disabled = false
	show()

# Displays drawn card for the player
func card_drawn(card):
	set_movable(false)
	set_at_spawn(true)
	$PlayerInterface.display_drawn_card(card)

# Allow player movement
func set_movable(value):
	movable = value

# Return the player's current hand
func get_hand() -> Array:
	return hand

# Add card to player's hand
func add_to_hand(card) -> void:
	hand.append(card)

# Remove card from player's hand
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

# NOTE 
#func _on_body_entered(_body):
	#hide() # Player disappears after being hit.
	#hit.emit()
	## Must be deferred as we can't change physics properties on a physics callback.
	# This tells godot to disable collision shape when safe (set_deferred) so that the 
	# his signal isn't repeatedly sent
	#$CollisionShape2D.set_deferred("disabled", true)

func set_at_spawn(value) -> void:
	at_spawn = value

func set_at_table(value) -> void:
	at_table = value

func trade(drawn_card, selected_card):
	$"..".trade(drawn_card, selected_card)
