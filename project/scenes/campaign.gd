class_name Campaign
extends Node2D

const CAMERA_SPEED := 256
const BATTLE_SCENE := preload("res://scenes/battle.tscn") as PackedScene
const CLEARING_BUTTON := preload("res://gui/clearing_button.tscn") as PackedScene

@export var progress: CampaignProgress

@onready var _current_clearing := $Forest/Clearings/StartingClearing as Clearing
@onready var _camera := $Camera2D as Camera2D
@onready var _adjacent_clearing_list := $Forest/Gui/AdjacentClearings as Node2D
@onready var _char_info := $Forest/Gui/CurrentClearing as Node2D
@onready var _woodland := $Forest/Woodland


func _ready() -> void:
	_woodland.call_deferred("generate_woodland")
	if not progress:
		return
	if progress.current_clearing:
		print("Starting at %s" % progress.current_clearing)
		_current_clearing = get_node(progress.current_clearing) as Clearing
	_setup_options()


func _setup_options() -> void:
	_char_info.position = _current_clearing.position
	for child in _adjacent_clearing_list.get_children():
		child.queue_free()
	for clearing in _current_clearing.adjacent_clearings:
		var button := CLEARING_BUTTON.instantiate() as ClearingButton
		_adjacent_clearing_list.add_child(button)
		button.position = clearing.position
		button.clearing = clearing
		button.clearing_selected.connect(func(): _move_to_clearing(clearing))


func _clear_fog(clearing: Clearing, duration: float) -> void:
#	var tween := create_tween()
	# TODO: Get particular fog bits
	# TODO: Fade out / Recede 
	pass


func _move_to_clearing(clearing: Clearing) -> void:
	var clearing_path := clearing.get_path()
	progress.visited_clearings.push_back(clearing_path)
	var duration := 0.6
	var tween := create_tween()
	_clear_fog(clearing, duration)
	tween.tween_property(_char_info, "position", clearing.position, duration)
	# TODO: If the new clearing isn't sufficiently in the centre of the screen, pan the camera
	tween.parallel().tween_property(_camera, "position", _camera.position, duration)
	await tween.finished
	_current_clearing = clearing
	_setup_options()
	if _current_clearing is StartingClearing:
		pass
	elif _current_clearing is BattleClearing:
		var battle := _current_clearing as BattleClearing
		var chance := randf()
		if chance < battle.battle_probability and battle.possible_encounters.size() > 0:
			var enemy := battle.possible_encounters.pick_random() as EnemyData
			await _battle(enemy)
			print("After the battle")
	elif _current_clearing is BossClearing:
		print("boss")
	elif _current_clearing is ShrineClearing:
		print("shrine")
	progress.current_clearing = clearing_path
	progress.cleared_clearings.push_back(clearing_path)


func _battle(enemy: EnemyData) -> void:
	var battle := BATTLE_SCENE.instantiate() as BattleScene
	battle.player = progress
	battle.character = progress.character
	battle.enemies = [enemy]
	# TODO: Show battle enemy (vs thing)
	await SceneTransition.push_scene(battle) # TODO: Battle transition!


func _open_settings() -> void:
	pass


func _save_and_quit() -> void:
	SceneTransition.transition_to_packed(load("res://scenes/title.tscn") as PackedScene)


func _process(_delta: float) -> void:
	var camera_movement := Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	_camera.position += camera_movement * _delta * 256
	_camera.position.x = clampf(_camera.position.x, _camera.limit_left, _camera.limit_right-_camera.get_viewport_rect().size.x)
	_camera.position.y = clampf(_camera.position.y, _camera.limit_top, _camera.limit_bottom-_camera.get_viewport_rect().size.y)
