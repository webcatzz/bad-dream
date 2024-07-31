class_name Trait extends Resource


enum Type {
	ANIMA,
	
	STRENGTH,
	TEMPERANCE,
	MONOLITH,
	RUST,
	SLOTH,
	VENGEFUL,
}


static func add(type: Type, actor: Actor) -> void:
	match type:
		Type.STRENGTH: actor.attack += 1
		Type.TEMPERANCE: actor.attack -= 1


static func remove(type: Type, actor: Actor) -> void:
	match type:
		Type.STRENGTH: actor.attack -= 1
		Type.TEMPERANCE: actor.attack += 1



# getters

static func name(type: Type) -> String:
	return Type.keys()[type].capitalize()


static func describe(type: Type) -> String:
	match type:
		Type.ANIMA: return "Keep going."
		Type.STRENGTH: return "+1 attack."
		Type.TEMPERANCE: return "-1 attack."
		Type.MONOLITH: return "+1 MONOLITH."
		Type.RUST: return "-1 MONOLITH."
		Type.SLOTH: return "Start battles asleep."
		Type.VENGEFUL: return "When hit, counterattack."
		_: return ""
