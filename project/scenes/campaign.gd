class_name Campaign
extends Node2D

const CAMERA_SPEED := 256
const BATTLE_SCENE := preload("res://scenes/battle.tscn") as PackedScene
const CLEARING_BUTTON := preload("res://gui/clearing_button.tscn") as PackedScene

@export var progress: CampaignProgress

@onready var _fog := $Fog as Node2D
@onready var _fog_clearing_list := $Fog/Clearings as Node2D
@onready var _current_clearing := $Forest/Clearings/StartingClearing as Clearing
@onready var _camera := $Camera2D as Camera2D
@onready var _adjacent_clearing_list := $Forest/Gui/AdjacentClearings as Node2D
@onready var _char_info := $Forest/Gui/CurrentClearing as Node2D
@onready var _woodland := $Forest/Woodland


func _ready() -> void:
	_woodland.call_deferred("generate_woodland")
	if not progress:
		return
	progress.visited_clearings.clear()
	progress.current_clearing = ""
	if not progress.current_clearing.is_empty():
		print("[Campaign] Starting at %s" % progress.current_clearing)
		_current_clearing = get_node(progress.current_clearing) as Clearing
	_setup_clearings()
	_setup_options()


func _setup_clearings() -> void:
	_fog.visible = true
	for clearing_path in progress.visited_clearings:
		var clearing := get_node(clearing_path) as Clearing
		clearing.times_visited += 1
		clearing.visible = true
	for child in _fog_clearing_list.get_children():
		var clearing := child as FogClearing
		clearing.visible = (clearing.clearing.times_visited > 0)
	if progress.visited_clearings.is_empty():
		await get_tree().create_timer(0.5).timeout
		_move_to_clearing(_current_clearing)


func _setup_options() -> void:
	_char_info.position = _current_clearing.position
	for child in _adjacent_clearing_list.get_children():
		child.queue_free()
	for clearing in _current_clearing.adjacent_clearings:
		var button := CLEARING_BUTTON.instantiate() as ClearingButton
		_adjacent_clearing_list.add_child(button)
		button.position = clearing.position
		button.clearing = clearing
		button.player = progress
		button.clearing_selected.connect(func(): _move_to_clearing(clearing))


func _clear_fog(clearing: Clearing, duration: float) -> void:
	const transparent := Color(1, 1, 1, 0)
	const revealed := Color(1, 1, 1, 1)
	@warning_ignore("unassigned_variable")
	var fog_clearings: Array[FogClearing]
	fog_clearings.assign(_fog_clearing_list.get_children().filter(func(child: Node) -> bool:
		return child is FogClearing and (child as FogClearing).clearing == clearing))
	if fog_clearings.is_empty():
		print("[Campaign] No fog clearings for clearing %s" % clearing.name)
		return
	var tween := create_tween()
	for fog_clearing in fog_clearings:
		fog_clearing.visible = true
		fog_clearing.modulate = transparent
		var delay := randf_range(0, 0.4) # IDEA: This could be based of distance from middle
		tween.parallel().tween_property(fog_clearing, "modulate", revealed, duration).set_delay(delay)


func _is_clearing_on_screen(clearing: Clearing) -> bool:
	var width := _camera.get_viewport_rect().size.x / 4
	var height := _camera.get_viewport_rect().size.y / 4
	var offset := clearing.position - _camera.position
	if absf(offset.x) > width:
		return false
	if absf(offset.y) > height:
		return false
	return true


func _move_to_clearing(clearing: Clearing) -> void:
	var clearing_path := clearing.get_path()
	progress.visited_clearings.push_back(clearing_path)
	var duration := 0.6
	var tween := create_tween()
	if clearing.times_visited == 0:
		_clear_fog(clearing, duration*2)
	clearing.times_visited += 1
	tween.tween_property(_char_info, "position", clearing.position, duration)
	if not _is_clearing_on_screen(clearing):
		var offset := clearing.position - _current_clearing.position
		# TODO: Rethink this camera motion
		tween.parallel().tween_property(_camera, "position", _camera.position + offset, duration)
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
	elif _current_clearing is BossClearing:
		print("[Campaign] Entering boss")
	elif _current_clearing is ShrineClearing:
		print("[Campaign] Entering shrine")
	progress.current_clearing = clearing_path
	progress.cleared_clearings.push_back(clearing_path)


func _battle(enemy: EnemyData) -> void:
	var battle := BATTLE_SCENE.instantiate() as BattleScene
	battle.player = progress
	battle.character = progress.character
	battle.enemies = [enemy]
	await SceneTransition.push_scene(battle) # TODO: Battle transition!
	_camera.make_current()


func _open_settings() -> void:
	pass


func _save_and_quit() -> void:
	SceneTransition.transition_to_packed(load("res://scenes/title.tscn") as PackedScene)


func _process(_delta: float) -> void:
	var camera_movement := Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	_camera.position += camera_movement * _delta * 256
	var width := _camera.get_viewport_rect().size.x
	var height := _camera.get_viewport_rect().size.y
	_camera.position.x = clampf(_camera.position.x, _camera.limit_left+width/2, _camera.limit_right-width/2)
	_camera.position.y = clampf(_camera.position.y, _camera.limit_top+height/2, _camera.limit_bottom-height/2)
