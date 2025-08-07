extends Control

signal started_game
signal quit_game

@export var host_controls: Array[Control] = []

@export var player_card: PackedScene
@export var player_cards: HBoxContainer
@export var player_spawner: MultiplayerSpawner
@export_file("*tscn") var next_scene 

func _ready() -> void:
	if !multiplayer.is_server():
		for control in host_controls:
			control.hide()
	
	player_spawner.spawn_function = _ms_player
	
	if multiplayer.is_server():
		# The server is responsible for spawning all players.
		_spawn_all_players_on_server()
		
		# Connect the server to peer_connected signal to handle new players
		multiplayer.peer_connected.connect(func(id: int) -> void: spawn_player_card(id))
		
		# Connect to peer_disconnected to remove player cards
		multiplayer.peer_disconnected.connect(func(id: int) -> void: 
			var client_pc = player_cards.get_node_or_null(str(id))
			if client_pc:
				client_pc.queue_free()
		)

func _spawn_all_players_on_server() -> void:
	# This function runs ONLY on the server.
	
	# Spawn the server's own player (authority ID 1)
	spawn_player_card(1)
	
	# Spawn all connected clients' players
	for peer_id in multiplayer.get_peers():
		spawn_player_card(peer_id)

func spawn_player_card(authority_pid: int) -> void:
	# This function runs only on the server. It will create and sync the player card.
	var client_pc = player_card.instantiate()
	client_pc.name = str(authority_pid)
	player_cards.add_child(client_pc)

func _ms_player(authority_pid: int) -> PackedScene:
	# This function is used by the MultiplayerSpawner. 
	# It must return a PackedScene, not an instance.
	# The MultiplayerSpawner handles the instantiation and syncing.
	return player_card

func _on_start_pressed() -> void:
	started_game.emit()
	Server.load_game.rpc(next_scene)

func _on_quit_pressed() -> void:
	multiplayer.multiplayer_peer.close()
	quit_game.emit()
