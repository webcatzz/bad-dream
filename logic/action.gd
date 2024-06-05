class_name Action extends Resource
## Actions used during battle.
## Actions are unique per-actor, but are reused multiple times.


signal delay_changed(value: int)
signal triggered
signal finished

enum Type {NONE, FIRE, OCEAN, SPIRAL, HOLY, PROFANE, HEALING}
enum Knockback {NONE, VECTOR, BLAST}
enum Result {NONE, HIT, CRITICAL, MISSED, EVADED}

@export var name: String = "Action"
@export_multiline var description: String

# damage
@export var base_strength: int ## Base amount of strength.
@export var dice: int ## Number of dice to roll when calculating strength.
@export var type: Type

# misc
@export var shape: BitShape ## The action's area of effect.
@export var status_effect: StatusEffect
@export var delay: int ## Number of turns that should end before this action triggers.
@export var needs_focus: bool ## If [code]true[/code], [member cause] may not act until the action is finished.

# knockback
@export_group("Knockback", "knockback_")
@export var knockback_type: Knockback
@export var knockback_vector: Vector2i

# buffers
var strength: int
var delay_left: int
var result: Result

# nodes
var cause: Actor
var splash: Splash


## Starts the action.
## If [member delay] is 0, triggers immediately.
## Otherwise, triggers after [param delay] turns.
func start() -> void:
	if delay:
		delay_left = delay
		Battle.turn_ended.connect(_decrement_delay)
	else:
		await trigger()


## Triggers the action. Identical to [method run], but also emits signals.
func trigger() -> void:
	triggered.emit()
	await run()
	finished.emit()


## Runs effects on all actors in range.
func run() -> void:
	var affected: Array[Actor] = _get_affected_actors()
	
	if affected:
		strength = await _get_strength()
		
		for actor: Actor in affected:
			actor.bear_action(self)



# virtual

## Fetches the action's strength.
func _get_strength() -> int:
	if dice:
		return await cause.node.dice.sum(dice, base_strength)
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
		trigger()
