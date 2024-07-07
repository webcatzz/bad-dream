class_name Action extends Resource
## Actions used during battle.
## Actions are unique per-actor, but are reused multiple times.


signal finished

enum Type {NONE, FIRE, OCEAN, SPIRAL, HOLY, PROFANE, HEALING}
enum Knockback {NONE, LINE, BLAST}

@export var name: String = "Action"
@export_multiline var description: String

# damage
@export var base_strength: int ## Base amount of strength.
@export var dice: int ## Number of dice to roll when calculating strength.
@export var type: Type ## Damage type. See [enum Type].
@export var shape: BitMap ## The action's area of effect.

# delay
@export_group("Delay")
@export var delay: int ## Number of turns that should end before this action triggers.

# knockback
@export_group("Knockback", "knockback_")
@export var knockback_type: Knockback
@export var knockback_vector: Vector2i

# statuses
@export_group("Status effects")
@export var status_effect: StatusEffect

# buffers
var strength: int
var affected: Array[Actor] ## [Actor]s affected by this action.


## Starts the action. If [member delay] is 0, triggers immediately, otherwise triggers after [param delay] turns.
func start(cause: Actor) -> void:
	if delay:
		_countdown(cause, delay)
	else:
		await run(cause)
		cause.action_taken.emit()


## Runs effects on all actors in range.
func run(cause: Actor) -> void:
	affected = _get_affected_actors(cause.current_splash)
	
	if affected:
		strength = await _get_strength(cause)
		
		for actor: Actor in affected:
			actor.recieve_action(self, cause)



# delay

func _countdown(cause: Actor, turns: int) -> void:
	while turns:
		# TODO: confirm every turn whether to continue focusing or end the action
		# TODO: end when battle ends
		await Battle.turn_ended
		turns -= 1
	
	await cause.turn_started
	await run(cause)
	cause.action_taken.emit()



# strength

## Returns the action's strength.
func _get_strength(cause: Actor) -> int:
	if dice:
		return await cause.node.dice.sum(dice, base_strength, type != Type.HEALING and _might_kill())
	else:
		return base_strength


## Returns true if this action might kill an [Actor] in range.
func _might_kill() -> bool:
	var max_damage: int = base_strength + dice * 6
	for actor in affected:
		if actor.calculate_damage(max_damage, type) > actor.health:
			return true
	return false



# splash

## Fetches a list of affected actors.
func _get_affected_actors(splash: Splash) -> Array[Actor]:
	return splash.get_actors() if shape else Battle.order



# misc

func _to_string() -> String:
	return name


func get_color() -> Color:
	match type:
		Type.FIRE:
			return Game.PALETTE.red
		Type.SPIRAL:
			return Game.PALETTE.dark_green
		Type.OCEAN:
			return Game.PALETTE.blue
		Type.HEALING:
			return Game.PALETTE.light_green
		_:
			return Game.PALETTE.white
