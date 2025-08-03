extends Node
signal loaded()

@onready var deck_cards = []
const CARD_SCENE_PATH: String = "res://interactable objects/scenes/card.tscn"
#TODO Game need to connect signals from every player ("area entered") to tables and spawns
# Called when the node enters the scene tree for the first time.

@export_file("*tscn") var next_scene
@export var player_scene: PackedScene

func activate() -> void:
	pass

func load_scene() -> void:
	await get_tree().create_timer(SceneManager.WAIT).timeout
	loaded.emit()


func _ready() -> void:
	generate_deck()
	$OnlineEntities/MultiplayerSpawner.spawn_function = _ms_player
	#$Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# NOTE, need to add powerup cards functionality
## Generates our card deck!
func generate_deck() -> void:
	for i in 4:
		for j in 13:
			var card_scene = preload(CARD_SCENE_PATH)
			var card = card_scene.instantiate()
			card.set_suit(i + 1)
			card.set_rank(j + 1)
			deck_cards.append(card)

## Deals out and returns a "hand" of 7 cards
func deal() -> Array:
	var hand = []
	for i in 7:
		var card = deck_cards.pick_random()
		hand.append(card)
		#TODO: remember to add cards back to deck
		deck_cards.erase(card)
	return hand

# Draws a random card from the deck
func draw() -> Node:
	var card = deck_cards.pick_random()
	return card

# TODO: TEST THIS
# Replaces drawn card ^^ with card player selected to trade
func trade(drawn_card, player_card) -> void:
	deck_cards.append(player_card)
	deck_cards.erase(drawn_card)

# NOTE tutorial has this named game_over()... NOt suitable to our purposes
func _on_player_hit() -> void:
	pass # Replace with function body.

func new_game():
	$StartTimer.start()

#NOTE the tutorial had this start two other timers....
func _on_start_timer_timeout() -> void:
	pass # Replace with function body.
	

#TODO
# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	new_game()
	pass
	
#var node = Node3D.new()
	#node.call("rotate", Vector3(1.0, 0.0, 0.0), 1.571)
	## Option 3: Signal.connect() with an implicit Callable for the defined function.
	#button.button_down.connect(_on_button_down)


#NOTE: Multiplayer Logic

func spawn_player(authority_pid: int) -> void:
	$OnlineEntities/MultiplayerSpawner.spawn(authority_pid)

func _ms_player(authority_pid: int) -> Player:
	var player = player_scene.instantiate()
	player.name = str(authority_pid)
	player.set_game($".")
	player.start($P1StartPosition.position)
	return player

func _on_connection_manager_joining() -> void:
	pass # Replace with function body.


func _on_lobby_started_game() -> void:
	_spawn_players()

func _spawn_players() -> void:
	spawn_player(1) # server's player
	
	for peer in multiplayer.get_peers():
		spawn_player(peer)
	
