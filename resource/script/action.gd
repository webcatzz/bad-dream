class_name Action extends Resource
## Actions used during battle.
## Actions are unique per-actor, but are reused multiple times.


signal delay_finished
signal finished

enum Type {NONE, FIRE, OCEAN, SPIRAL, HOLY, PROFANE, HEALING}
enum Knockback {NONE, LINE, BLAST}
enum Result {NONE, HIT, CRITICAL, MISSED, EVADED}

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
@export var needs_focus: bool ## If [code]true[/code], [member cause] may not act until the action is finished.

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
var delay_left: int
var result: Result

# nodes
var cause: Actor ## The [Actor] this action belongs to.
var splash: Splash = Splash.new(self) ## Node representation.


## Starts the action.
## If [member delay] is 0, triggers immediately.
## Otherwise, triggers after [param delay] turns.
func start() -> void:
	if delay:
		delay_left = delay
		Battle.turn_ended.connect(_decrement_delay.unbind(1))
	else:
		await run()
		finished.emit()


## Runs effects on all actors in range.
func run() -> void:
	affected = _get_affected_actors()
	
	if affected:
		strength = await _get_strength()
		
		for actor: Actor in affected:
			actor.recieve_action(self)



# internal

## Fetches the action's strength.
func _get_strength() -> int:
	if dice:
		return await cause.node.dice.sum(dice, base_strength, _might_kill())
	else:
		return base_strength


## Fetches a list of affected actors.
func _get_affected_actors() -> Array[Actor]:
	if shape:
		return splash.get_actors()
	else:
		return Battle.order


## Decrements [member delay_left]. If it becomes 0, the action triggers.
func _decrement_delay() -> void:
	delay_left -= 1
	
	if delay_left == 0:
		Battle.turn_ended.disconnect(_decrement_delay)
		await run()
		finished.emit()
	
	elif needs_focus:
		pass # TODO: confirm every turn whether to continue focusing or end the action


## Returns [code]true[/code] if this action might kill an [Actor] in range.
func _might_kill() -> bool:
	var max_damage: int = base_strength + dice * 6
	for actor in affected:
		if actor.calculate_damage(max_damage, type) > actor.health:
			return true
	return false


func _to_string() -> String:
	return name + " (" + cause.to_string() + ")"
