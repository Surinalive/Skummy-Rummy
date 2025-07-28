extends StaticBody2D

#NOTE Not sure how connecting signal to two diff objects/nodes will work out....

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# TODO need to implement some type of timer to make sure player can't 
# continuously draw.....
func draw_card() -> Control:
	return $"..".draw()

func _on_area_2d_body_entered(body: Node2D) -> void:
	body.set_at_spawn(true, self)
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	body.set_at_spawn(false)
