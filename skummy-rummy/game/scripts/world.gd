class_name World
extends Node2D

@export var player_scene: PackedScene
@export var player_spawner: MultiplayerSpawner

func _ready() -> void:
	Server.player_loaded.rpc_id(1)
	player_spawner.spawn_function = _ms_player
	
	# The server is responsible for spawning all players.
	if multiplayer.is_server():
		_spawn_all_players_on_server()

# This function runs ONLY on the server.
func _spawn_all_players_on_server() -> void:
	
	# Spawn the server's own player (authority ID 1)
	player_spawner.spawn(1)
	
	# Spawn all connected clients' players
	for peer_id in multiplayer.get_peers():
		player_spawner.spawn(peer_id)

func _ms_player(authority_pid: int) -> Player:
	var player = player_scene.instantiate()
	player.name = str(authority_pid)
	
	# Assign different start positions based on the player ID
	#TODO
	if authority_pid == 1:
		player.set_position($P1StartPosition.position)
	else:
		player.set_position($P2StartPosition.position)

	# Only displays THIS player's interface
	if authority_pid != multiplayer.get_unique_id():
		player.hide_interface()
		
	return player
