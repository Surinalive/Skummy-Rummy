extends CanvasLayer

signal transitioned_in()
signal transitioned_out()

@onready var animPlayer: AnimationPlayer = $AnimationPlayer
@onready var colorrect: ColorRect = $ColorRect
const WAIT = 0.1

func _ready() -> void:
	SceneManager.visible = false

#Plays given animation before scene loads
func  transition_in(anim_name: String) -> void:
	SceneManager.visible = true
	animPlayer.play(anim_name)
	
#Plays given animation right before next scene loads
func transition_out(anim_name: String) -> void:
	SceneManager.visible = true
	animPlayer.play(anim_name)
	
func transition_to(scene: String, anim_name: String) -> void:
	#Play chosen animation to transition into scene
	transition_in(anim_name + "_in")
	await transitioned_in
	
	var new_scene = load(scene).instantiate()
	var root: Window = get_tree().get_root()
	
	#Removes previous scene
	root.get_child(root.get_child_count() - 1).free()
	root.add_child(new_scene)
	
	#Loads new scene
	new_scene.load_scene()
	await new_scene.loaded
	
	#Play chosen animation to transition out of scene
	transition_out(anim_name + "_out")
	await transitioned_out
	
	#Execute any logic that is required as the new scene becomes active (backgroung music)
	new_scene.activate()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#SceneManager.visible = false
	if anim_name.ends_with("_in"):
		transitioned_in.emit()
	elif anim_name.ends_with("_out"):
		transitioned_out.emit()
		SceneManager.visible = false
