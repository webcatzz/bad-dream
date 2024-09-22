class_name Trait extends Resource


enum Type {
	ANIMA,
	# attack
	STRENGTH,
	TEMPERANCE,
	# defense
	GLEAM,
	RUST,
	# knockback
	# special
	SLOTH,
	VENGE,
	BACKSTAB,
}


static func apply(type: Type, actor: Actor) -> void:
	match type:
		Type.STRENGTH: actor.attack += 1
		Type.TEMPERANCE: actor.attack -= 1
		Type.GLEAM: actor.defense += 1
		Type.RUST: actor.defense -= 1


static func unapply(type: Type, actor: Actor) -> void:
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
		Type.STRENGTH: return "+1 ATK."
		Type.TEMPERANCE: return "-1 ATK."
		Type.GLEAM: return "+1 DEF."
		Type.RUST: return "-1 DEF."
		Type.SLOTH: return "Start battles asleep."
		Type.VENGE: return "When hit, hit back."
		Type.BACKSTAB: return "+1 ATK from behind."
		_: return ""


static func color(type: Type) -> Color:
	match type:
		Type.ANIMA: return Palette.TEXT_NORMAL
		_: return Palette.TEXT_NORMAL
