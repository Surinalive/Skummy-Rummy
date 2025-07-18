extends StaticBody2D
@export var allow_draw = false
@onready var player 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if allow_draw and event.is_action_pressed("action"):
		var card = $"..".draw()
		player.card_drawn(card)

func _on_area_2d_body_entered(body: Node2D) -> void:
	allow_draw = true
	player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	allow_draw = false
	player = null
