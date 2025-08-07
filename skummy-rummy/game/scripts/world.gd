class_name World
extends Node2D

@export var player_scene: PackedScene
@export var player_spawner: MultiplayerSpawner

signal player_spawned(player_node)

func _ready() -> void:
	player_spawner.spawn_function = _ms_player
	
	if multiplayer.is_server():
		Server.set_world()
		# The server is responsible for spawning all players.
		_spawn_all_players_on_server()

func _spawn_all_players_on_server() -> void:
	# This function runs ONLY on the server.
	
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
		player.start($P1StartPosition.position)
	else:
		player.start($P2StartPosition.position)
	
	player_spawned.emit(player)
	return player
