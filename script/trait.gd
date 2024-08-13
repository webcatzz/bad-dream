class_name Trait extends Resource


enum Type {
	ANIMA,
	# attack
	STRENGTH,
	TEMPERANCE,
	# defense
	GLEAM,
	RUST,
	# special
	SLOTH,
	VENGE,
}


static func add(type: Type, actor: Actor) -> void:
	match type:
		Type.STRENGTH: actor.attack += 1
		Type.TEMPERANCE: actor.attack -= 1
		Type.GLEAM: actor.defense += 1
		Type.RUST: actor.defense -= 1


static func remove(type: Type, actor: Actor) -> void:
	match type:
		Type.STRENGTH: actor.attack -= 1
		Type.TEMPERANCE: actor.attack += 1
		Type.GLEAM: actor.defense -= 1
		Type.RUST: actor.defense += 1



# getters

static func name(type: Type) -> String:
	return Type.keys()[type].capitalize()


static func describe(type: Type) -> String:
	match type:
		Type.ANIMA: return "Keep going."
		Type.STRENGTH: return "+1 STRIKE."
		Type.TEMPERANCE: return "-1 STRIKE."
		Type.GLEAM: return "+1 MONOLITH."
		Type.RUST: return "-1 MONOLITH."
		Type.SLOTH: return "Start battles asleep."
		Type.VENGE: return "When hit, counterattack."
		_: return ""
