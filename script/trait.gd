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

const descriptions: PackedStringArray = [
	"Keep going.", # ANIMA
	
	"+1 attack.", # STRENGTH
	"-1 attack.", # TEMPERANCE
	"+1 MONOLITH.", # MONOLITH
	"-1 MONOLITH.", # RUST
	"Start battles asleep.", # SLOTH
	"When hit, counterattack.", # VENGEFUL
]


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
	return Type.keys()[type]


static func describe(type: Type) -> String:
	return descriptions[type]
