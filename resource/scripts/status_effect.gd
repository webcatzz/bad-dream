class_name StatusEffect extends Resource
## Effects used during battle.
## Effects are duplicated before being applied to an [Actor].


signal ended ## Emitted when the effect ends.

enum Type {
	BURN, ## Deals [member strength] damage every time [member target] takes an action.
	POISON, ## Deals [member strength] damage every time [member target]'s turn ends.
	VANISH, ## Guarantees evasion.
	SLOW, ## Decreases [member target.tiles_per_turn] by [member strength].
	DOOM, ## Deals [member strength] damage at the end of its duration.
}

@export var type: Type ## Dictates the effect's behavior. See [enum Type].
@export var duration: int = 1 ## How long the effect lasts. Decremented every time [member target]'s turn ends. When it hits 0, the effect ends.
@export var strength: int = 1 ## General measure of strength. Behavior varies based on [member type].

var target: Actor ## The [Actor] this effect targets.


## Starts the effect.
func start() -> void:
	target.turn_ended.connect(_decrement_duration)
	Battle.ended.connect(end)
	
	match type:
		Type.BURN:
			target.action_taken.connect(target.damage.bind(strength, Action.Type.FIRE), CONNECT_REFERENCE_COUNTED)
		Type.POISON:
			target.turn_ended.connect(target.damage.bind(strength, Action.Type.SPIRAL), CONNECT_REFERENCE_COUNTED)
		Type.VANISH:
			target.modifiers.evasion += 1
		Type.SLOW:
			target.modifiers.tiles_per_turn -= strength


## Stacks the effect with another of the same type.
func stack(with: StatusEffect) -> void:
	duration += with.duration
	strength += with.strength


## Ends the effect.
func end() -> void:
	target.turn_ended.disconnect(_decrement_duration)
	
	match type:
		Type.BURN:
			target.action_taken.disconnect(target.damage)
		Type.POISON:
			target.turn_ended.disconnect(target.damage)
		Type.VANISH:
			target.modifiers.evasion -= 1
		Type.SLOW:
			target.modifiers.tiles_per_turn += strength
		Type.DOOM:
			target.damage(strength)
	
	ended.emit()



# internal

func _decrement_duration() -> void:
	duration -= 1
	if duration == 0: end()
