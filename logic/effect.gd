class_name StatusEffect extends Resource
## Effects used during battle.
## Effects are duplicated before they are applied to an [Actor].


signal ended ## Emitted when the effect ends.

enum Type {
	BURN, ## Deals damage every time [member target] takes an action.
	POISON, ## Deals damage every time [member target]'s turn ends.
	VANISH, ## Guarantees evasion.
}

@export var type: Type
@export var duration: int = 1 ## How long the effect lasts. Decremented every time [member target]'s turn ends. When it hits 0, the effect ends.
@export var strength: int = 1 ## How strong the effect is. Implementation varies per effect.

var target: Actor ## The [Actor] this effect targets.


## Starts the effect.
func start() -> void:
	target.turn_ended.connect(_decrement_duration)
	
	match type:
		Type.BURN:
			target.action_taken.connect(target.damage.bind(1, Action.Type.FIRE), CONNECT_REFERENCE_COUNTED)
		Type.POISON:
			target.turn_ended.connect(target.damage.bind(1, Action.Type.SPIRAL), CONNECT_REFERENCE_COUNTED)
		Type.VANISH:
			var old_evasion: float = target.evasion
			target.evasion = 100
			ended.connect(func() -> void: target.evasion = old_evasion)


## Stacks the effect with another of the same type.
func stack(with: StatusEffect) -> void:
	duration += with.duration
	strength += with.strength


## Ends the effect.
func end() -> void:
	match type:
		Type.BURN:
			target.action_taken.disconnect(target.damage)
		Type.POISON:
			target.turn_ended.disconnect(target.damage)
		Type.VANISH:
			pass
	
	ended.emit()



# internal

func _decrement_duration() -> void:
	duration -= 1
	if duration == 0: end()
