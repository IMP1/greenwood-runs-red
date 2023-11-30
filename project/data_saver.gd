extends Node

const Target = CardAction.Target
const StatusType = Status.StatusType
const Duration = Status.Duration


func _ready() -> void:
	var root_path := "res://data/core/"
	for character in _create_characters():
		var filename := character.name.to_lower() + ".tres"
		ResourceSaver.save(character, root_path + "characters/" + filename)
	for enemy in _create_enemies():
		var filename := enemy.name.to_lower() + ".tres"
		ResourceSaver.save(enemy, root_path + "enemies/" + filename)


func attack(amount: int, piercing:=false) -> CardActionAttack:
	var action := CardActionAttack.new()
	action.name = "Attack %d" % amount
	action.target = Target.ENEMY
	if piercing:
		action.name += " 🛡"
	action.damage = amount
	action.piercing = piercing
	return action


func move(distance: int, jumping:= false) -> CardActionMove:
	var action := CardActionMove.new()
	action.name = "Move %d" % distance
	action.target = Target.SELF
	if jumping:
		action.name += " 🦅"
	action.distance = distance
	action.jumping = jumping
	return action


func defend(defence: int) -> CardActionDefend:
	var action = CardActionDefend.new()
	action.name = "Defend %d" % defence
	action.target = Target.SELF
	action.defence = defence
	return action


func evade(distance: int) -> CardActionEvade:
	var action := CardActionEvade.new()
	action.name = "Evade %d" % distance
	action.target = Target.SELF
	action.distance = distance
	return action


func status(target: Target, type: StatusType, amount: int, duration: Duration) -> CardActionApplyStatus:
	var action := CardActionApplyStatus.new()
	action.name = "%s %s %d" % [
		StatusType.keys()[type].to_pascal_case(), 
		Target.keys()[target].to_pascal_case(),
		amount]
	action.target = target
	action.status = Status.new()
	action.status.type = type
	action.status.amount = amount
	action.status.duration = duration
	return action


func energise(energy: int) -> CardActionEnergise:
	var action := CardActionEnergise.new()
	action.name = "Energise %d" % energy
	action.target = Target.SELF
	action.energy = energy
	return action


func heal(amount: int) -> CardActionHeal:
	var action := CardActionHeal.new()
	action.name = "Heal %d" % amount
	action.target = Target.SELF
	action.heal = amount
	return action


func prepare(action_to_prepare: CardAction) -> CardActionPrepare:
	var action := CardActionPrepare.new()
	action.name = "Prepare %s" % action_to_prepare.name
	action.target = Target.SELF
	action.then(action_to_prepare)
	return action


func give(amount: int, card_to_give: CardData) -> CardActionGiveCard:
	var action := CardActionGiveCard.new()
	action.name = "Give %s x%d" % [card_to_give.name, amount]
	action.target = Target.ENEMY
	action.card = card_to_give
	action.amount = amount
	return action


func card(card_name: String, energy_cost: int, exhausted: bool, actions: Array[CardAction]) -> CardData:
	var c := CardData.new()
	c.name = card_name
	c.energy_cost = energy_cost
	c.actions = actions
	c.is_exhausted = exhausted
	return c


func _create_characters() -> Array[CharacterData]:
	return [
		_create_fox(),
		_create_badger(),
		_create_owl(),
		_create_snake(),
		_create_bat(),
	]


func _create_enemies() -> Array[EnemyData]:
	return [
		_create_rat(),
	]


func _create_fox() -> CharacterData:
	var character := CharacterData.new()
	character.name = "Fox"
	character.colour = Color("c04500")
	character.portrait = load("res://data/core/portraits/fox.png") as Texture2D
	character.battler_sprite = load("res://data/core/sprites/fox.tres") as SpriteFrames
	character.max_health = 10
	character.energy_per_turn = 3
	character.max_hand_size = 5
	character.deck = []
	
	for i in 2:
		var c := card("Scratch", 1, false, [attack(1)])
		character.deck.append(c)
	for i in 2:
		var c := card("Dodge", 0, true, [evade(1)])
		character.deck.append(c)
	for i in 2:
		var c := card("Leap", 2, false, [move(1).then(attack(1))])
		character.deck.append(c)
	for i in 1:
		var c := card("Taunt", 2, false, [status(Target.ENEMY, StatusType.ENRAGED, 1, Duration.END_OF_SCENARIO)])
		character.deck.append(c)
	for i in 1:
		var c := card("Feint", 1, false, [status(Target.ENEMY, StatusType.FROZEN, 1, Duration.END_OF_THIS_TURN)])
		character.deck.append(c)
	for i in 1:
		var c := card("Bite", 2, false, [attack(1, false).then(status(Target.ENEMY, StatusType.WOUNDED, 1, Duration.END_OF_SCENARIO))])
		character.deck.append(c)
	for i in 1:
		var c := card("Nimble Step", 1, false, [move(1), evade(1)])
		character.deck.append(c)
	
	return character


func _create_badger() -> CharacterData:
	var character := CharacterData.new()
	character.name = "Badger"
	character.colour = Color("868889")
	character.portrait = load("res://data/core/portraits/badger.png") as Texture2D
	character.battler_sprite = load("res://data/core/sprites/badger.tres") as SpriteFrames
	character.max_health = 14
	character.energy_per_turn = 3
	character.max_hand_size = 5
	character.deck = []
	
	for i in 2:
		var c := card("Slash", 2, false, [attack(2)])
		character.deck.append(c)
	for i in 2:
		var c := card("Scratch", 1, false, [attack(1)])
		character.deck.append(c)
	for i in 2:
		var c := card("Step", 1, false, [move(1)])
		character.deck.append(c)
	for i in 2:
		var c := card("Hunker", 1, false, [defend(1)])
		character.deck.append(c)
	for i in 1:
		var c := card("Bide", 1, false, [prepare(energise(2))])
		character.deck.append(c)
	for i in 1:
		var c := card("Fury", 1, false, [status(Target.SELF, StatusType.RECKLESS, 1, Duration.END_OF_NEXT_TURN)])
		character.deck.append(c)
	for i in 1:
		var c := card("Dual Swipes", 4, false, [attack(2), attack(2)])
		character.deck.append(c)
	for i in 1:
		var c := card("Lick Wounds", 2, false, [heal(2)])
		character.deck.append(c)
	
	return character


func _create_owl() -> CharacterData:
	var character := CharacterData.new()
	character.name = "Owl"
	character.colour = Color("789de0")
	character.portrait = load("res://data/core/portraits/owl.png") as Texture2D
	character.battler_sprite = load("res://data/core/sprites/owl.tres") as SpriteFrames
	character.max_health = 9
	character.energy_per_turn = 3
	character.max_hand_size = 5
	character.deck = []
	
	for i in 2:
		var c := card("Flit", 1, false, [move(1, true)])
		character.deck.append(c)
	for i in 2:
		var c := card("Scratch", 1, false, [attack(1)])
		character.deck.append(c)
	for i in 2:
		var c := card("Peck", 2, false, [attack(1), attack(1)])
		character.deck.append(c)
	for i in 1:
		var c := card("Rake", 2, false, [move(1, true).then(attack(2))])
		character.deck.append(c)
	for i in 1:
		var c := card("Dodge", 1, false, [evade(1)])
		character.deck.append(c)
	for i in 1:
		var c := card("Fly", 2, false, [move(2, true)])
		character.deck.append(c)
	for i in 1:
		var c := card("Screech", 1, false, [status(Target.ENEMY, StatusType.SLOWED, 1, Duration.END_OF_THIS_TURN)])
		character.deck.append(c)
	
	return character


func _create_snake() -> CharacterData:
	var character := CharacterData.new()
	character.name = "Snake"
	character.colour = Color("4a9a56")
	character.portrait = load("res://data/core/portraits/snake.png") as Texture2D
	character.battler_sprite = load("res://data/core/sprites/snake.tres") as SpriteFrames
	character.max_health = 8
	character.energy_per_turn = 3
	character.max_hand_size = 4
	character.deck = []
	
	for i in 2:
		var c := card("Venomous Bite", 2, false, [attack(1).then(status(Target.ENEMY, StatusType.POISONED, 1, Duration.END_OF_SCENARIO))])
		character.deck.append(c)
	for i in 2:
		var c := card("Coil", 1, false, [defend(1)])
		character.deck.append(c)
	for i in 1:
		var c := card("Piercing Fang", 1, false, [attack(0).then(status(Target.ENEMY, StatusType.WOUNDED, 1, Duration.END_OF_SCENARIO))])
		character.deck.append(c)
	for i in 1:
		var c := card("Paralyse", 2, false, [status(Target.ENEMY, StatusType.IMMOBILISED, 1, Duration.END_OF_THIS_TURN)])
		character.deck.append(c)
	for i in 1:
		var c := card("Dodge", 1, false, [evade(1)])
		character.deck.append(c)
	for i in 1:
		var c := card("Bite", 2, false, [attack(2)])
		character.deck.append(c)
	
	return character


func _create_bat() -> CharacterData:
	var character := CharacterData.new()
	character.name = "Bat"
	character.colour = Color("8571d1")
	character.portrait = load("res://data/core/portraits/bat.png") as Texture2D
	character.battler_sprite = load("res://data/core/sprites/bat.tres") as SpriteFrames
	character.max_health = 6
	character.energy_per_turn = 3 # Maybe 4 if too weak?
	character.max_hand_size = 6
	character.deck = []
	
	for i in 2:
		var c := card("Identify", 1, false, [status(Target.SELF, StatusType.PRECISE, 1, Duration.END_OF_NEXT_TURN)])
		character.deck.append(c)
	for i in 2:
		var c := card("Shroud", 1, false, [status(Target.ENEMY, StatusType.BLIND, 1, Duration.END_OF_THIS_TURN)])
		character.deck.append(c)
	for i in 1:
		var c := card("Swarm", 3, false, [attack(1), attack(1), attack(1)])
		character.deck.append(c)
	for i in 1:
		var c := card("Dodge", 1, false, [evade(1)])
		character.deck.append(c)
	for i in 1:
		var c := card("Flit", 1, false, [move(1, true)])
		character.deck.append(c)
	for i in 1:
		var c := card("Swoop", 2, false, [move(1, true).then(attack(1).then(evade(1)))])
		character.deck.append(c)
	for i in 1:
		var c := card("Regroup", 0, false, [energise(1)])
		character.deck.append(c)
	for i in 1:
		var c := card("Life Steal", 1, false, [attack(1).then(heal(1))])
		character.deck.append(c)
	for i in 1:
		var c := card("Gash", 1, false, [attack(1).then(status(Target.ENEMY, StatusType.WOUNDED, 1, Duration.END_OF_SCENARIO))])
		character.deck.append(c)
	for i in 1:
		var c := card("Weaken", 0, true, [status(Target.ENEMY, StatusType.POISONED, 1, Duration.END_OF_SCENARIO)])
		character.deck.append(c)
	
	return character


func _create_rat() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.name = "Rat"
	enemy.portrait = null
	enemy.battler_sprite = load("res://data/core/sprites/rat.tres") as SpriteFrames
	enemy.max_health = 4
	enemy.energy_per_turn = 3
	enemy.max_hand_size = 5
	enemy.experience_awarded = 4
	enemy.min_char_level = -1
	enemy.max_char_level = 2
	enemy.deck = []
	enemy.card_rewards = {}
	
	for i in 4:
		var c := card("Scratch", 1, false, [attack(1)])
		enemy.deck.append(c)
	for i in 4:
		var c := card("Dodge", 1, false, [evade(1)])
		enemy.deck.append(c)
	for i in 2:
		var c := card("Scurry", 1, false, [move(1)])
		enemy.deck.append(c)
	for i in 2:
		var c := card("Dart", 1, false, [move(1), status(Target.SELF, StatusType.HASTENED, 1, Duration.END_OF_NEXT_TURN)])
		enemy.deck.append(c)
	
	var fox_rewards: Array[CardData] = []
	enemy.card_rewards["fox"] = fox_rewards
	for i in 1:
		var c := card("Dart", 1, false, [move(1), status(Target.SELF, StatusType.HASTENED, 1, Duration.END_OF_NEXT_TURN)])
		fox_rewards.append(c)
	for i in 1:
		var c := card("Whimper", 0, true, [status(Target.ENEMY, StatusType.WEAKENED, 1, Duration.END_OF_THIS_TURN)])
		fox_rewards.append(c)
	for i in 1:
		var c := card("Charge", 1, true, [attack(1), move(1), attack(1)])
		fox_rewards.append(c)
	for i in 1:
		var c := card("Anticipate", 1, false, [evade(2)])
		fox_rewards.append(c)
	
	var badger_rewards: Array[CardData] = []
	enemy.card_rewards["badger"] = badger_rewards
	for i in 1:
		var c := card("Charge", 1, true, [attack(1), move(1), attack(1)])
		badger_rewards.append(c)
	for i in 1:
		var c := card("Rage", 2, false, [
			status(Target.SELF, StatusType.ENRAGED, 1, Duration.END_OF_NEXT_TURN), 
			status(Target.SELF, StatusType.RECKLESS, 1, Duration.END_OF_NEXT_TURN)])
		badger_rewards.append(c)
	for i in 1:
		var c := card("Lunge", 2, false, [status(Target.ENEMY, StatusType.FROZEN, 1, Duration.END_OF_THIS_TURN), attack(1)])
		badger_rewards.append(c)
	for i in 1:
		var c := card("Track", 1, true, [status(Target.ENEMY, StatusType.FROZEN, 2, Duration.END_OF_THIS_TURN)])
		badger_rewards.append(c)
	
	var owl_rewards: Array[CardData] = []
	enemy.card_rewards["owl"] = owl_rewards
	for i in 1:
		var c := card("Track", 1, true, [status(Target.ENEMY, StatusType.FROZEN, 2, Duration.END_OF_THIS_TURN)])
		owl_rewards.append(c)
	for i in 1:
		var c := card("Strafe", 1, true, [move(1).then(attack(1)).then(move(1))])
		owl_rewards.append(c)
	for i in 1:
		var c := card("Anticipate", 1, false, [evade(2)])
		owl_rewards.append(c)
	for i in 1:
		var c := card("Charge", 1, true, [attack(1), move(1), attack(1)])
		owl_rewards.append(c)
	
	var snake_rewards: Array[CardData] = []
	enemy.card_rewards["snake"] = snake_rewards
	for i in 1:
		var c := card("Track", 1, true, [status(Target.ENEMY, StatusType.FROZEN, 2, Duration.END_OF_THIS_TURN)])
		snake_rewards.append(c)
	for i in 1:
		var c := card("Dart", 1, false, [move(1), status(Target.SELF, StatusType.HASTENED, 1, Duration.END_OF_NEXT_TURN)])
		snake_rewards.append(c)
	for i in 1:
		var c := card("Lunge", 2, false, [status(Target.ENEMY, StatusType.FROZEN, 1, Duration.END_OF_THIS_TURN), attack(1)])
		snake_rewards.append(c)
	for i in 1:
		var c := card("Glare", 1, true, [give(4, card("Stall", 1, false, []))])
		snake_rewards.append(c)
	
	var bat_rewards: Array[CardData] = []
	enemy.card_rewards["bat"] = bat_rewards
	for i in 1:
		var c := card("Dart", 1, false, [move(1), status(Target.SELF, StatusType.HASTENED, 1, Duration.END_OF_NEXT_TURN)])
		bat_rewards.append(c)
	for i in 1:
		var c := card("Whimper", 0, true, [status(Target.ENEMY, StatusType.WEAKENED, 1, Duration.END_OF_THIS_TURN)])
		bat_rewards.append(c)
	for i in 1:
		var c := card("Strafe", 1, true, [move(1).then(attack(1)).then(move(1))])
		bat_rewards.append(c)
	for i in 1:
		var c := card("Anticipate", 1, false, [evade(2)])
		bat_rewards.append(c)
	
	return enemy


func _create_rabbit() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.name = "Rabbit"
	enemy.portrait = null
	enemy.battler_sprite = load("res://data/core/sprites/rat.tres") as SpriteFrames
	enemy.max_health = 6
	enemy.energy_per_turn = 3
	enemy.max_hand_size = 5
	enemy.experience_awarded = 6
	enemy.min_char_level = -1
	enemy.max_char_level = 2
	enemy.deck = []
	enemy.card_rewards = {}
	
	for i in 4:
		var c := card("Scratch", 1, false, [attack(1)])
		enemy.deck.append(c)
	for i in 2:
		var c := card("Scurry", 1, false, [move(1)])
		enemy.deck.append(c)
	for i in 2:
		var c := card("Dart", 1, false, [move(1), status(Target.SELF, StatusType.HASTENED, 1, Duration.END_OF_NEXT_TURN)])
		enemy.deck.append(c)
	for i in 2:
		var c := card("Leap", 1, false, [move(1).then(attack(1))])
		enemy.deck.append(c)
	
	var fox_rewards: Array[CardData] = []
	enemy.card_rewards["fox"] = fox_rewards
	for i in 1:
		var c := card("Dart", 1, false, [move(1), status(Target.SELF, StatusType.HASTENED, 1, Duration.END_OF_NEXT_TURN)])
		fox_rewards.append(c)
	for i in 1:
		var c := card("Whimper", 0, true, [status(Target.ENEMY, StatusType.WEAKENED, 1, Duration.END_OF_THIS_TURN)])
		fox_rewards.append(c)
	for i in 1:
		var c := card("Charge", 1, true, [attack(1), move(1), attack(1)])
		fox_rewards.append(c)
	for i in 1:
		var c := card("Anticipate", 1, false, [evade(2)])
		fox_rewards.append(c)
	
	var badger_rewards: Array[CardData] = []
	enemy.card_rewards["badger"] = badger_rewards
	for i in 1:
		var c := card("Charge", 1, true, [attack(1), move(1), attack(1)])
		badger_rewards.append(c)
	for i in 1:
		var c := card("Rage", 2, false, [
			status(Target.SELF, StatusType.ENRAGED, 1, Duration.END_OF_NEXT_TURN), 
			status(Target.SELF, StatusType.RECKLESS, 1, Duration.END_OF_NEXT_TURN)])
		badger_rewards.append(c)
	for i in 1:
		var c := card("Lunge", 2, false, [status(Target.ENEMY, StatusType.FROZEN, 1, Duration.END_OF_THIS_TURN), attack(1)])
		badger_rewards.append(c)
	for i in 1:
		var c := card("Track", 1, true, [status(Target.ENEMY, StatusType.FROZEN, 2, Duration.END_OF_THIS_TURN)])
		badger_rewards.append(c)
	
	var owl_rewards: Array[CardData] = []
	enemy.card_rewards["owl"] = owl_rewards
	for i in 1:
		var c := card("Track", 1, true, [status(Target.ENEMY, StatusType.FROZEN, 2, Duration.END_OF_THIS_TURN)])
		owl_rewards.append(c)
	for i in 1:
		var c := card("Strafe", 1, true, [move(1).then(attack(1)).then(move(1))])
		owl_rewards.append(c)
	for i in 1:
		var c := card("Anticipate", 1, false, [evade(2)])
		owl_rewards.append(c)
	for i in 1:
		var c := card("Charge", 1, true, [attack(1), move(1), attack(1)])
		owl_rewards.append(c)
	
	var snake_rewards: Array[CardData] = []
	enemy.card_rewards["snake"] = snake_rewards
	for i in 1:
		var c := card("Track", 1, true, [status(Target.ENEMY, StatusType.FROZEN, 2, Duration.END_OF_THIS_TURN)])
		snake_rewards.append(c)
	for i in 1:
		var c := card("Dart", 1, false, [move(1), status(Target.SELF, StatusType.HASTENED, 1, Duration.END_OF_NEXT_TURN)])
		snake_rewards.append(c)
	for i in 1:
		var c := card("Lunge", 2, false, [status(Target.ENEMY, StatusType.FROZEN, 1, Duration.END_OF_THIS_TURN), attack(1)])
		snake_rewards.append(c)
	for i in 1:
		var c := card("Glare", 1, true, [give(4, card("Stall", 1, false, []))])
		snake_rewards.append(c)
	
	var bat_rewards: Array[CardData] = []
	enemy.card_rewards["bat"] = bat_rewards
	for i in 1:
		var c := card("Dart", 1, false, [move(1), status(Target.SELF, StatusType.HASTENED, 1, Duration.END_OF_NEXT_TURN)])
		bat_rewards.append(c)
	for i in 1:
		var c := card("Whimper", 0, true, [status(Target.ENEMY, StatusType.WEAKENED, 1, Duration.END_OF_THIS_TURN)])
		bat_rewards.append(c)
	for i in 1:
		var c := card("Strafe", 1, true, [move(1).then(attack(1)).then(move(1))])
		bat_rewards.append(c)
	for i in 1:
		var c := card("Anticipate", 1, false, [evade(2)])
		bat_rewards.append(c)
	
	return enemy

