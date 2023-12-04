class_name BattleScene
extends Node2D

const BATTLER_OBJECT := preload("res://object/battler.tscn") as PackedScene
const ENEMY_INFO_GUI := preload("res://gui/enemy_battler_info.tscn") as PackedScene
const CARD_GUI_OBJ := preload("res://gui/card.tscn") as PackedScene
const PLAYER_BATTLER_NAME = "Player"

# TODO: Have a map/arena object with starting positions, and obstacles and stuff
@export var player: CampaignProgress
@export var character: CharacterData
@export var enemies: Array[EnemyData]

var _round_number: int = 1
var _player_batter: Battler
var _enemy_battlers: Array[Battler]

@onready var _battler_list := $Battlers as Node2D
@onready var _positions := $Positions as Node2D
@onready var _round_count := $CanvasLayer/BattleInfo/RoundNumber as Label
@onready var _end_player_turn := $CanvasLayer/Actions/EndTurn as Button
@onready var _player_battler_ui := $CanvasLayer/PlayerInfo as PlayerBattlerInfo
@onready var _player_actions := $CanvasLayer/Actions as Control
@onready var _enemy_gui_list := $CanvasLayer/EnemyInfo as Control
@onready var _player_hand := $CanvasLayer/Hand as Control
@onready var _modal := $CanvasLayer/Modal as Modal
@onready var _camera := $Camera2D as Camera2D

# TODO: Limit attacks to their range
# TODO: Movement
# TODO: Evasion


func _ready() -> void:
	_camera.make_current()
	if not player:
		return
	_setup_characters()
	_refresh_ui()
	while not _is_battle_over():
		await _process_round()
	_end_battle()


func _process_round() -> void:
	await _start_round()
	_refresh_ui()
	if _is_battle_over(): return
	for child in _battler_list.get_children():
		var battler := child as Battler
		await _start_turn(battler)
		_refresh_ui()
		if battler == _player_batter:
			await _player_turn(battler)
		else:
			await _ai_turn(battler)
		_refresh_ui()
		await _end_turn(battler)
		_refresh_ui()
		if _is_battle_over(): return
	await _end_round()
	_refresh_ui()


func _end_battle() -> void:
	_modal.show_menu("Debrief")
	# TODO: Show results
	# TODO: Show rewards (reward options)
	# TODO: Push result to global progress variable


func _confirm_end_battle() -> void:
	SceneTransition.pop_scene()


func _is_battle_over() -> bool:
	if _player_batter.health <= 0:
		return true
	for battler in _enemy_battlers:
		if battler.health <= 0:
			return true
	return false


func _setup_characters() -> void:
	_player_batter = BATTLER_OBJECT.instantiate() as Battler
	_player_batter.character = character
	_player_batter.name = PLAYER_BATTLER_NAME
	_battler_list.add_child(_player_batter)
	# TODO: Get starting position for player battler
	_player_batter.set_deferred("position", _positions.get_child(5).position)
	_enemy_battlers = []
	for i in enemies.size():
		var enemy := BATTLER_OBJECT.instantiate() as Battler
		enemy.name = "Enemy %d" % (i+1)
		enemy.character = enemies[i]
		_battler_list.add_child(enemy)
		enemy.set_deferred("position", _positions.get_child(i).position)
		var gui := ENEMY_INFO_GUI.instantiate() as EnemyBattlerInfo
		gui.name = "Enemy %d" % (i+1)
		gui.battler = enemy
		_enemy_gui_list.add_child(gui)
		_enemy_battlers.append(enemy)
	_player_battler_ui.player = _player_batter
	_player_battler_ui.player_name = player.player_name
	_player_battler_ui.refresh()


func _refresh_ui() -> void:
	_round_count.text = "Round %d" % _round_number
	_player_battler_ui.refresh()
	for child in _enemy_gui_list.get_children():
		var gui := child as EnemyBattlerInfo
		gui.refresh()


func _refresh_actions() -> void:
	for child in _player_hand.get_children():
		_player_hand.remove_child(child)
		child.queue_free()
	for card in _player_batter.hand:
		var card_gui := CARD_GUI_OBJ.instantiate() as CardGui
		card_gui.data = card
		var enemy := _enemy_battlers[0] # TODO: Get enemy somehow
		card_gui.pressed.connect(_play_card.bind(card, _player_batter, enemy))
		_player_hand.add_child(card_gui)
		card_gui.set_deferred("disabled", not _player_batter.can_play_card(card))


func _start_round() -> void:
	for child in _battler_list.get_children():
		var battler := child as Battler
		battler.defence = 0
		battler.evasion = 0
		battler.energy = 0
		# TODO: Start-of-round Modifiers
		# Prepared Actions
		for action in battler.prepared_actions:
			var subject := battler
			var enemy := _player_batter if _enemy_battlers.has(battler) else _enemy_battlers[0]
			_perform_action(action, subject, enemy)
		# Round Statuses
		battler.evasion -= battler.get_status_level(Status.StatusType.FROZEN)
		battler.defence -= battler.get_status_level(Status.StatusType.EXPOSED)
		for status in battler.statuses:
			if status.type == Status.StatusType.WOUNDED:
				var damage := clampi(status.amount, 0, battler.health)
				battler.health -= damage


func _end_round() -> void:
	for child in _battler_list.get_children():
		var battler := child as Battler
		battler.statuses = battler.statuses.filter(func(s: Status) -> bool: 
			return s.duration != Status.Duration.END_OF_THIS_ROUND)
		for status in battler.statuses:
			if status.duration == Status.Duration.END_OF_NEXT_ROUND:
				status.duration = Status.Duration.END_OF_THIS_ROUND
	_round_number += 1


func _start_turn(battler: Battler) -> void:
	# TODO: Start-of-turn Modifiers
	for i in battler.hand_size:
		battler.draw_card()
	battler.energy += battler.character.energy_per_turn
	_refresh_ui()
	_refresh_actions()


func _end_turn(battler: Battler) -> void:
	battler.discard_hand()
	battler.statuses = battler.statuses.filter(func(s: Status) -> bool: 
		return s.duration != Status.Duration.END_OF_THIS_TURN)
	for status in battler.statuses:
		if status.duration == Status.Duration.END_OF_NEXT_TURN:
			status.duration = Status.Duration.END_OF_THIS_TURN
	_refresh_ui()
	_refresh_actions()


func _ai_turn(battler: Battler) -> void:
	print("[Battle] Starting AI Turn")
	print(battler.hand.map(func(c: CardData) -> String: return c.name))
	await get_tree().create_timer(1).timeout
	var options := battler.hand.filter(func(c: CardData): return battler.can_play_card(c))
	print(options.map(func(c: CardData) -> String: return c.name))
	while not options.is_empty() and not _is_battle_over():
		await get_tree().create_timer(0.5).timeout
		var card := options.pick_random() as CardData
		await _play_card(card, battler, _player_batter)
		options = battler.hand.filter(func(c: CardData): return battler.can_play_card(c))
	print("[Battle] Ending AI Turn")
	# TODO: AI? Random? Different AIs?


func _player_turn(_battler: Battler) -> void:
	print("[Battle] Starting Player Turn")
	_refresh_actions()
	_player_actions.visible = true
	await _end_player_turn.pressed
	_player_actions.visible = false
	print("[Battle] Ending Player Turn")


func _play_card(card: CardData, battler: Battler, target: Battler) -> void:
	print("[Battle] Playing '%s'" % card.name)
	battler.hand.remove_at(battler.hand.find(card))
	battler.energy -= card.energy_cost
	for action in card.actions:
		_perform_action(action, battler, target)
		_refresh_ui()
	if card.is_exhausted:
		battler.exhausted.append(card)
	else:
		battler.discard.append(card)
	_refresh_ui()
	if battler == _player_batter and _is_battle_over():
		_end_player_turn.pressed.emit()
	_refresh_actions()


func _perform_action(action: CardAction, subject: Battler, target: Battler) -> void:
	print("[Battle] Performing '%s'" % action.name)
	var should_continue := true
	if action is CardActionMove:
		var amount := (action as CardActionMove).distance
		amount += subject.get_status_level(Status.StatusType.HASTENED)
		amount -= subject.get_status_level(Status.StatusType.SLOWED)
		subject.movement += maxi(amount, 0)
		# TODO: Await the movement
	elif action is CardActionEnergise:
		subject.movement += (action as CardActionEnergise).energy
	elif action is CardActionDefend:
		subject.defence += (action as CardActionDefend).defence
	elif action is CardActionEvade:
		var can_evade := true
		if subject.get_status_level(Status.StatusType.ENRAGED) > 0:
			can_evade = false
		if subject.get_status_level(Status.StatusType.IMMOBILISED) > 0:
			can_evade = false
		var amount := (action as CardActionEvade).distance
		amount = maxi(amount, 0)
		if can_evade:
			subject.evasion += amount
		else:
			should_continue = false
	elif action is CardActionPrepare:
		subject.prepared_actions.append((action as CardActionPrepare).subactions)
	elif action is CardActionHeal:
		subject.statuses = subject.statuses.filter(func(s: Status) -> bool: return s.type != Status.StatusType.POISONED)
		subject.statuses = subject.statuses.filter(func(s: Status) -> bool: return s.type != Status.StatusType.WOUNDED)
		var amount := mini((action as CardActionHeal).heal, subject.character.max_health - subject.health)
		subject.health += amount
	elif action is CardActionApplyStatus:
		var battler: Battler
		match (action as CardActionApplyStatus).target:
			CardActionApplyStatus.Target.SELF:
				battler = subject
			CardActionApplyStatus.Target.ENEMY:
				battler = target
		battler.statuses.append((action as CardActionApplyStatus).status)
	elif action is CardActionAttack:
		var hits := true
		if subject.get_status_level(Status.StatusType.BLIND) > 0:
			hits = [hits, false].pick_random()
		# TODO: Defender evasion
		if hits:
			var piercing := (action as CardActionAttack).piercing or subject.get_status_level(Status.StatusType.PRECISE) > 0
			var poison := target.get_status_level(Status.StatusType.POISONED)
			var rage := subject.get_status_level(Status.StatusType.ENRAGED)
			var reckless_attack := subject.get_status_level(Status.StatusType.RECKLESS)
			var reckless_defence := target.get_status_level(Status.StatusType.RECKLESS)
			var damage := (action as CardActionAttack).damage
			if not piercing:
				damage -= target.defence
			damage += poison
			damage += reckless_attack
			damage += reckless_defence
			damage += rage
			damage = clampi(damage, 0, target.health)
			target.health -= damage
		else:
			should_continue = false
	if should_continue:
		for sub_action in action.subactions:
			_perform_action(sub_action, subject, target)
