extends Control

func _on_host_enet_pressed() -> void:
	Server.create_game()
	get_tree().change_scene_to_file("res://game/scenes/Lobby.tscn")

func _on_join_pressed() -> void:
	Server.join_game()
	get_tree().change_scene_to_file("res://game/scenes/Lobby.tscn")
