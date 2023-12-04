class_name Status
extends Resource

enum StatusType {
	WOUNDED, # Take damage every round
	POISONED, # Take additional damage from attacks
	BLIND, # Attacks have 50% chance to miss
	ENRAGED, # Can only use actions with attack; damage increased; won't evade
	IMMOBILISED, # Cannot move or evade
	SLOWED, # Movement actions distance reduced
	FROZEN, # Evasion reduced at start of round
	WEAKENED, # Attack damage reduced
	EXPOSED, # Defence reduced at start of round
	
	ENERGISED, # Energy increased
	PRECISE, # All attacks are piercing
	HASTENED, # Movement actions distance increased
	
	RECKLESS, # Do additional damage but take additional damage
}

enum Duration {
	END_OF_THIS_TURN,
	END_OF_NEXT_TURN,
	END_OF_THIS_ROUND,
	END_OF_NEXT_ROUND,
	END_OF_SCENARIO,
}

@export var type: StatusType
@export var amount: int
@export var duration: Duration


static func get_icon(status_type: StatusType) -> Texture2D:
	var name := StatusType.keys()[status_type] as String
	var path := "res://assets/statuses/%s.svg" % name.to_lower()
	if not ResourceLoader.exists(path):
		push_warning("[Status] Cannot find icon for status '%s'" % name)
		return null
	return ResourceLoader.load(path) as Texture2D


static func get_status_name(status_type: StatusType) -> String:
	var name := StatusType.keys()[status_type] as String
	return name.to_pascal_case()
