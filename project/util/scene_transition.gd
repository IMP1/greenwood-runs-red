extends CanvasLayer

var _scene_stack: Array[Node]

@onready var _previous_scene := $Crop/PreviousScene as TextureRect
@onready var _animation_player := $AnimationPlayer as AnimationPlayer
@onready var _crop := $Crop as Control


func _ready() -> void:
	visible = false


func _transition(transition: StringName, scene_switch: Callable) -> void:
	var size := _crop.size
	var screenshot := get_viewport().get_texture().get_image()
	await get_tree().process_frame
	var texture := ImageTexture.create_from_image(screenshot)
	_previous_scene.texture = texture
	visible = true
	
	scene_switch.call()

	_animation_player.play(transition)
	await _animation_player.animation_finished
	visible = false
	_crop.size = size


func transition_to_packed(next_scene: PackedScene, transition:=&"wipe_left") -> void:
	_transition(transition, get_tree().change_scene_to_packed.bind(next_scene))


func transition_to_scene(next_scene: Node, transition:=&"wipe_left") -> void:
	_transition(transition, func():
		get_tree().current_scene.queue_free()
		get_tree().root.add_child(next_scene)
		get_tree().current_scene = next_scene
	)


func push_scene(next_scene: Node, transition:=&"wipe_left") -> void:
	_transition(transition, func():
		_scene_stack.push_back(get_tree().current_scene)
		get_tree().root.add_child(next_scene)
		get_tree().current_scene = next_scene
	)
	await next_scene.tree_exiting


func pop_scene(transition:=&"wipe_left") -> void:
	_transition(transition, func():
		assert(_scene_stack.size() >= 1)
		get_tree().current_scene.queue_free()
		get_tree().current_scene = _scene_stack.pop_back() as Node
	)
