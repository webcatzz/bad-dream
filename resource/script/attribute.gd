class_name Attribute extends Resource
## Static class for [Actor]s' attributes.


enum Type {
	INDULGENCE,
	TEMPERANCE,
	SLOTH
}

const descriptions: PackedStringArray = [
	"Deal 20% more damage.", # INDULGENCE
	"Deal 20% less damage.", # TEMPERANCE
	"Start battles asleep.", # SLOTH
]


static func add(type: Type, actor: Actor) -> void:
	match type:
		Type.TEMPERANCE:
			pass
		Type.SLOTH:
			actor.battle_entered.connect(func() -> void:
				var sleep: StatusEffect = StatusEffect.new()
				sleep.type = StatusEffect.Type.SLEEP
				actor.add_status_effect(sleep)
			)
		_: pass


static func remove(type: Type, actor: Actor) -> void:
	match type:
		_: pass
