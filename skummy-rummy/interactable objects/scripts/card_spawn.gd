class_name CardSpawner
extends StaticBody2D

### SIGNALS LOGIC

func _on_area_2d_body_entered(body: Player) -> void:
	body.set_at_spawn(true, self)
	
func _on_area_2d_body_exited(body: Player) -> void:
	body.set_at_spawn(false)

### CARD LOGIC

func draw_card():
	
	if $Timer.is_stopped():
		$Timer.start(5.0)
		return Server.draw()
	
	return null
