class_name Actor extends Resource


# orientation
signal position_changed(value: Vector2i)
signal facing_changed(value: Vector2i)
# stats
signal health_changed(value: int)
signal health_changed_by(value: int)
signal evaded
signal defeated
# turns
signal turn_started
signal turn_ended
signal action_taken
signal path_extended
signal path_backtracked
# effects
signal effect_added(effect: Effect)
signal effect_removed(effect: Effect)

# appearance
@export var name: String = "Actor"
@export var sprite: Texture2D = load("res://asset/sprite/default.png")
@export var portrait: Texture2D = load("res://asset/portrait/default.png")
@export_multiline var description: String = "..."

# stats
@export_group("Stats")
## Maximum value for [member health].
@export var max_health: int = 10
## When [member health] hits [code]0[/code], the actor is defeated.
var health: int:
	set(value):
		health_changed_by.emit(value - health)
		health = min(value, max_health)
		health_changed.emit(health)

## Knockback is decreased by this amount.
@export var resistance: int
## Chance to evade an attack and move backward one tile.
@export_range(0, 1, 0.01) var evasion: float

## Maximum number of tiles traveled per turn.
## Also used to order actors' turns during battle.
@export var tiles_per_turn: int = 1
## Maximum number of actions taken per turn.
@export var actions_per_turn: int = 1
## The number of tiles traveled this turn.
var tiles_traveled: int:
	set(value):
		tiles_traveled = value
		end_turn_if_exhausted()
## The number of actions taken this turn.
var actions_taken: int:
	set(value):
		if value > actions_taken: action_taken.emit()
		actions_taken = value
		end_turn_if_exhausted()

# type affinities
@export_group("Affinities")
## Damage types whose strength is doubled.
@export var weak_against: Array[Action.Type]
## Damage types whose strength is halved.
@export var strong_against: Array[Action.Type]

# actions
@export_group("Actions")
## [Action]s available during battle.
@export var actions: Array[Action]
## Immediately started when the battle begins.
@export var battlecry: Action

# orientation
## The actor's current position.
var position: Vector2i:
	set(value):
		position = value
		position_changed.emit(position)
## The direction the actor is facing.
var facing: Vector2i = Vector2i.DOWN:
	set(value):
		facing = value
		facing_changed.emit(facing)

# battle
var in_battle: bool
## List of previous positions the actor has been in during their turn.
var path: Array[Dictionary]
## A list of [Effect]s the actor is affected by. Add effects using [method add_effect].
var effects: Array
## The action the actor is focusing on.
var focusing: Action

var node: ActorNode


func _init() -> void:
	_export_init.call_deferred()


# Called once @export properties are initialized.
func _export_init() -> void:
	health = max_health
	
	for i: int in actions.size():
		actions[i] = actions[i].duplicate()
		actions[i].cause = self



# movement

## Sets [member position] to [param to_pos] and sets [member facing] to the direction of motion.
func move(to_pos: Vector2i) -> void:
	var displacement: Vector2i = to_pos - position
	var axis: int = displacement.abs().max_axis_index()
	facing = (Vector2i.DOWN if axis else Vector2i.RIGHT) * signi(displacement[axis])
	position = to_pos


func push(vector: Vector2i) -> void:
	facing = -vector
	vector.x = max(abs(vector.x) - resistance, 0) * sign(vector.x)
	vector.y = max(abs(vector.y) - resistance, 0) * sign(vector.y)
	position += vector



# battle turns

## Starts the actor's turn.
func take_turn() -> void:
	actions_taken = 0
	tiles_traveled = 0
	turn_started.emit()
	node.take_turn()
	await turn_ended


## Ends the actor's turn.
func end_turn() -> void:
	path.clear()
	turn_ended.emit()


## Performs an action.
func take_action(action: Action) -> void:
	actions_taken += 1
	if action.ends_turn: end_turn()
	
	await action.start()
	
	if actions_taken >= actions_per_turn: end_turn()


## Records the current position and face to [member path].
func extend_path() -> void:
	path.append({"position": position, "facing": facing})
	tiles_traveled += 1
	path_extended.emit()


## Moves back to a previous state on [member path].
func backtrack_path() -> void:
	var point: Dictionary = path.pop_back()
	position = point.position
	facing = point.facing
	tiles_traveled -= 1
	path_backtracked.emit()


## Returns true if the actor has not exhausted [member actions_per_turn].
func can_act() -> bool:
	return actions_taken < actions_per_turn


## Returns true if the actor has not exhausted [member tiles_per_turn].
func can_move() -> bool:
	return tiles_traveled < tiles_per_turn


## Ends the actor's turn if the actor cannot do anything else.
func end_turn_if_exhausted() -> void:
	if not (can_act() or can_move()):
		end_turn()



# action effects

func bear_action(action: Action) -> bool:
	if randf() < evasion:
		evade(action.cause.facing)
		return false
	else:
		if action.strength:
			if action.type == Action.Type.HEALING: heal(action.strength)
			else: damage(action.strength, action.type)
		if action.knockback_type:
			push(Iso.rotate_grid_vector(action.knockback_vector, action.cause.facing))
		if action.effect:
			add_effect(action.effect.duplicate())
		return true


## Modifies [param amount] according to the actor's type affinities,
## then subtracts it from [member health].
func damage(amount: int, type: Action.Type = Action.Type.NONE) -> void:
	if weak_against.has(type): amount *= 2
	elif strong_against.has(type): amount /= 2
	
	health -= amount
	
	if health <= 0: defeated.emit()


## Increases [member health] by [param amount].
func heal(amount: int) -> void:
	damage(-amount, Action.Type.HEALING)


## Evades an attack.
func evade(direction: Vector2i) -> void:
	facing = -direction
	position += direction



# effects

## Adds an [Effect]. Active effects are stored in [member effects].
func add_effect(effect: Effect) -> void:
	effect.target = self
	effect.start()
	
	effects.append(effect)
	effect_added.emit(effect)
	effect.ended.connect(remove_effect.bind(effect))


## Removes an [Effect]. Called when an effect ends.
func remove_effect(effect: Effect) -> void:
	effects.erase(effect)
	effect_removed.emit(effect)



# string conversion

func _to_string() -> String:
	return name
