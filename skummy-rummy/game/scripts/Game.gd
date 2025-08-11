class_name Game
extends Node
## logic for scene manager
#signal loaded()

signal hands_synchronized
## server logic
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const CARD_SCENE_PATH: String = "res://interactable objects/scenes/card.tscn"

## multiplayer logic
const PORT = 7000 #I can choose my own port...
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

const PLAYER : PackedScene = preload("res://player/scenes/player.tscn")

var deck_cards = {}

## This will contain player info for every player,
## with the keys being each player's unique IDs.
var players = {}

## This is the local player info. This should be modified locally
## before the connection is made. It will be passed to every other peer.
## For example, the value of "name" can be set to something the player
## entered in a UI scene.
var player_info = {"name": "Name"}

var player_hands = {}

var players_loaded = 0

#TODO Game need to connect signals from every player ("area entered") to tables and spawns
# Called when the node enters the scene tree for the first time.

## logic for scene manager
#func activate() -> void:
	#pass
#func load_scene() -> void:
	#await get_tree().create_timer(SceneManager.WAIT).timeout
	#loaded.emit()


func _ready() -> void:
	## multiplayer logic
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# NOTE, need to add powerup cards functionality
## Generates our card deck!
func generate_deck() -> void:
	if not multiplayer.is_server():
		return
	var key = 0
	for i in 4:
		for j in 13:
			var card_data = {
				"deck_id" : key,
				"suit" : i + 1,
				"rank" : j + 1
			}
			deck_cards.set(key,card_data)
			key += 1
	
## Deals out all player hands
func deal_hands() -> void:
	# Only the server should deal the hands.
	# Check if the current peer is the server.
	if not multiplayer.is_server():
		return

	for player in players:
		var hand : Array[Dictionary]= []
		for i in 7:
			var card_data = draw()
			hand.append(card_data)

			#TODO: remember to add cards back to deck
			deck_cards.erase(deck_cards.find_key(card_data))
		player_hands[player] = hand
		
	# After dealing, need to broadcast the new state to all clients.
	rpc("sync_hands_with_clients", player_hands, deck_cards)

# This function is on the server
@rpc("unreliable", "call_local")
func sync_hands_with_clients(new_player_hands, new_deck_cards):
	# This function runs on all clients (and the server)
	# Update the local hands dictionary
	self.player_hands = new_player_hands
	self.deck_cards = new_deck_cards
	print("Peer ", multiplayer.get_unique_id(), " Received synchronized hands")
	
	hands_synchronized.emit()

@rpc("unreliable", "authority")
func get_player_hand() -> Array:
	var id = get_multiplayer().get_remote_sender_id()
	if player_hands.has(id):
		return player_hands[id]
	else:
		print("error")
		return []

#TODO redo with multiplayer in mind
# Draws a random card from the deck
@rpc("unreliable", "authority")
func draw() -> Dictionary:
	var random_key = deck_cards.keys().pick_random()
	var card = deck_cards.get(random_key)
	return card

# TODO: TEST THIS

func server_trade(drawn_card_data : Dictionary, player_card_data : Dictionary) -> void:
	var player_id = multiplayer.get_unique_id()
	print("hi")
	if !player_hands.has(player_id) or !player_hands[player_id].has(player_card_data):
		print("Server: Invalid discard request. Player ", player_id, " does not have this card.")
		return
	
	# First, find the key for the card data
	var key_to_erase = player_hands[player_id].find(player_card_data)

	# Check if a key was actually found (find_key returns null if not found)
	if key_to_erase != null:
	# Now, use erase with only the key as the argument
		player_hands[player_id].remove_at(key_to_erase)
	else:
		print("Server Error: Card data not found in hand for peer ", player_id)
		
	player_hands[player_id].append(drawn_card_data)
	print("Server: Player ", player_id, " traded a card.")
	deck_cards.set(player_card_data["deck_id"], player_card_data)
	deck_cards.erase(drawn_card_data["deck_id"])
	
	# Server tells everyone that the hand has changed
	rpc("sync_hands_with_clients", player_hands, deck_cards)

# Replaces drawn card ^^ with card player selected to trade
@rpc("unreliable", "any_peer")
func trade(drawn_card_data : Dictionary, player_card_data : Dictionary) -> void:
	# Get ID of the peer who sent the rpc
	var player_id = multiplayer.get_remote_sender_id()
	print("hi")
	if !player_hands.has(player_id) or !player_hands[player_id].has(player_card_data):
		print("Server: Invalid discard request. Player ", player_id, " does not have this card.")
		return
	
	# First, find the key for the card data
	var key_to_erase = player_hands[player_id].find(player_card_data)

	# Check if a key was actually found (find_key returns null if not found)
	if key_to_erase != null:
	# Now, use erase with only the key as the argument
		player_hands[player_id].remove_at(key_to_erase)
	else:
		print("Server Error: Card data not found in hand for peer ", player_id)
		
	player_hands[player_id].append(drawn_card_data)
	print("Server: Player ", player_id, " traded a card.")
	deck_cards.set(player_card_data["deck_id"], player_card_data)
	deck_cards.erase(drawn_card_data["deck_id"])
	
	# Server tells everyone that the hand has changed
	rpc("sync_hands_with_clients", player_hands, deck_cards)

## Removes a card from player hand (used in table melds)
func server_remove_from_player_hand(card_data) -> void:
	# Get ID of the peer who sent the rpc
	var player_id = multiplayer.get_unique_id()
	
	if !player_hands.has(player_id) or !player_hands[player_id].has(card_data):
		print("Server: Invalid remove request. Player ", player_id, " does not have this card.")
		return
		
	# Server removes card from players hand
	player_hands[player_id].remove_at(player_hands[player_id].find(card_data))
	print("Server: Player ", player_id, " traded a card.")
	
	# Server tells everyone that the hand has changed
	rpc("sync_hands_with_clients", player_hands, deck_cards)

@rpc("unreliable", "any_peer")
func remove_from_player_hand(card_data) -> void:
	# Get ID of the peer who sent the rpc
	var player_id = multiplayer.get_remote_sender_id()
	
	if !player_hands.has(player_id) or !player_hands[player_id].has(card_data):
		print("Server: Invalid remove request. Player ", player_id, " does not have this card.")
		return
		
	# Server removes card from players hand
	player_hands[player_id].remove_at(player_hands[player_id].find(card_data))
	print("Server: Player ", player_id, " traded a card.")
	
	# Server tells everyone that the hand has changed
	rpc("sync_hands_with_clients", player_hands, deck_cards)

# NOTE tutorial has this named game_over()... NOt suitable to our purposes
#func _on_player_hit() -> void:
	#pass # Replace with function body.

#func new_game():
	#$StartTimer.start()

#NOTE the tutorial had this start two other timers....
#func _on_start_timer_timeout() -> void:
	#pass # Replace with function body.
	#

#TODO
# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	generate_deck()
	deal_hands()

#var node = Node3D.new()
	#node.call("rotate", Vector3(1.0, 0.0, 0.0), 1.571)
	## Option 3: Signal.connect() with an implicit Callable for the defined function.
	#button.button_down.connect(_on_button_down)


## NOTE: Setting up of server
## create a server
func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	# The server must register itself as a player.
	var my_id = multiplayer.get_unique_id()
	players[my_id] = player_info
	player_connected.emit(my_id, player_info)
	
	print("server started")
	
## join server. Address must equal hosts
func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	print("client connecting to " + address)

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	players.clear()

## When the server decides to start the game from a UI scene,
## do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)
	start_game()

## Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			players_loaded = 0
	
## When a peer connects, send them my player info.
## This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)
	
	## Check if the game has already started and hands have been dealt.
	#if !player_hands.is_empty():
		#print("Server: Game is in progress, sending hand data to new peer.")
		#
		## We must use rpc_id() to send a targeted RPC to this new peer.
		## Send the entire synchronized hands dictionary so the new player
		## gets the full game state.
		#rpc_id(id, "sync_hands_with_clients", player_hands)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
