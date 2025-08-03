extends Node2D



func _on_host_pressed() -> void:
	Lobby.create_game()
	get_tree().change_scene_to_file("res://game/scenes/Game.tscn")


func _on_join_pressed() -> void:
	Lobby.join_game()
	#get_tree().change_scene_to_file("res://game/scenes/Game.tscn")
