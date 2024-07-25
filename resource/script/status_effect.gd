class_name StatusEffect extends Resource
## Status effects used during battle.


enum Type {
	BURN, ## Deals [member strength] damage every time [member target] takes an action.
	POISON, ## Deals [member strength] damage every time [member target]'s turn ends.
	VANISH, ## Guarantees evasion.
	SLOW, ## Decreases [member target.tiles_per_turn] by [member strength].
	DOOM, ## Deals [member strength] damage at the end of its duration.
	STUN, ## Makes [member target] unable to act.
	GUARD, ## Increases [member target]'s defense by [member strength].
	SLEEP,
}

@export var type: Type ## Dictates the effect's behavior. See [enum Type].
@export var duration: int = 1 ## How long the effect lasts. Decremented every time [member target]'s turn ends. When it hits 0, the effect ends.
@export var strength: int = 1 ## General measure of strength. Behavior varies based on [member type].


## Starts the effect.
func start(target: Actor) -> void:
	match type:
		Type.BURN:
			target.action_taken.connect(target.damage.bind(strength, Action.Type.FIRE), CONNECT_REFERENCE_COUNTED)
		Type.POISON:
			target.turn_ended.connect(target.damage.bind(strength, Action.Type.SPIRAL), CONNECT_REFERENCE_COUNTED)
		Type.VANISH:
			target.modifiers.evasion += 1
		Type.SLOW:
			target.modifiers.tiles_per_turn -= strength
		Type.STUN:
			target.modifiers.actions_per_turn -= 1000
			target.modifiers.tiles_per_turn -= 1000
		Type.GUARD:
			target.modifiers.defense += strength
	
	target.turn_ended.connect(_countdown.bind(target))
	Battle.ended.connect(end.bind(target))


## Ends the effect.
func end(target: Actor) -> void:
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
			if Battle.active: target.damage(strength)
		Type.STUN:
			target.modifiers.actions_per_turn += 1000
			target.modifiers.tiles_per_turn += 1000
		Type.GUARD:
			target.modifiers.defense -= strength
	
	target.turn_ended.disconnect(_countdown)
	Battle.ended.disconnect(end)
	target.remove_status_effect(self)



# getters

func get_type_string() -> String:
	return Type.keys()[type].to_lower()


func get_color() -> Color:
	match type:
		Type.BURN: return Game.PALETTE.red
		Type.POISON: return Game.PALETTE.light_green
		Type.SLOW: return Game.PALETTE.gray
		Type.DOOM: return Game.PALETTE.black
		Type.STUN: return Game.PALETTE.yellow
		Type.GUARD: return Game.PALETTE.light_blue
		Type.SLEEP: return Game.PALETTE.dark_blue
		_: return Game.PALETTE.white



# internal

func _countdown(target: Actor) -> void:
	for i: int in duration:
		# TODO: end when battle ends
		await target.turn_ended
	
	end(target)
