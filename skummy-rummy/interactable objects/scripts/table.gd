class_name Table
extends StaticBody2D

### SIGNALS LOGIC

func _on_area_2d_body_entered(body: Player) -> void:
	body.set_at_table(true,self) # should I send Object.get_instance_id()???

func _on_area_2d_body_exited(body: Player) -> void:
	body.set_at_table(false)

### CARD LOGIC
