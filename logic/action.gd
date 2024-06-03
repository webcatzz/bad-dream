class_name Action extends Resource
## Actions used during battle.
## Actions are unique per-actor, but are reused multiple times.


signal delay_changed(value: int)
signal triggered
signal finished(successful: bool)

enum Type {NONE, FIRE, OCEAN, SPIRAL, HOLY, PROFANE, HEALING}
enum Knockback {NONE, VECTOR, BLAST}

@export var name: String = "Action"
@export_multiline var description: String

@export var dice: int
@export var modifier: int
@export var type: Type

@export var shape: BitShape
@export var effect: Effect
@export var delay: int
@export var ends_turn: bool

@export_group("Knockback", "knockback_")
@export var knockback_type: Knockback
@export var knockback_vector: Vector2i

# nodes
var cause: Actor
var splash: Splash

# buffers
var strength: int


## Starts the action.
## If [member delay] is 0, triggers immediately.
## Otherwise, triggers after [param delay] turns.
func start() -> void:
	if delay:
		Battle.turn_ended.connect(_decrement_delay)
	else:
		await trigger()


func trigger() -> void:
	triggered.emit()
	
	var affected: Array[Actor] = _get_affected_actors()
	var successful: bool
	
	if affected:
		strength = await _get_strength()
		
		for actor: Actor in affected:
			if actor.bear_action(self):
				successful = true
	
	finished.emit(successful)


## Runs effects on [param actor].
func affect(actor: Actor, strength: int) -> void:
	if strength:
		if type == Type.HEALING: actor.heal(strength)
		else: actor.damage(strength, type)
	
	if knockback_type:
		actor.push(Vector2(knockback_vector).rotated(atan2(cause.facing.y, cause.facing.x)))
	if effect:
		actor.add_effect(effect.duplicate())



# virtual

## Fetches the action's strength.
func _get_strength() -> int:
	if dice:
		return await cause.node.dice.sum(dice, modifier)
	else:
		return modifier


## Fetches a list of affected actors.
func _get_affected_actors() -> Array[Actor]:
	if shape:
		return splash.get_actors()
	else:
		return Battle.order


## Decrements [member delay]. If it becomes 0, the action triggers.
func _decrement_delay() -> void:
	delay -= 1
	if delay == 0:
		Battle.turn_ended.disconnect(_decrement_delay)
		trigger()
