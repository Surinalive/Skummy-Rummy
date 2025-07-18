extends StaticBody2D
@onready var player 

#func _input(event: InputEvent) -> void:
	#if allow_draw and event.is_action_pressed("action"):
		#var card = $"..".draw()
		#player.display_card_drawn(card)
#
#func _on_area_2d_body_entered(body: Node2D) -> void:
	#allow_draw = true
	#player = body
#
#func _on_area_2d_body_exited(body: Node2D) -> void:
	#allow_draw = false
	#player = null
