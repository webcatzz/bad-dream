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
signal action_taken ## Emitted when an action is started.
signal path_extended
signal path_backtracked
signal battle_entered
signal battle_exited
# effects
signal status_effect_added(status_effect: StatusEffect)
signal status_effect_removed(status_effect: StatusEffect)

# appearance
@export var name: String = "Actor"
@export var sprite: Texture2D = load("res://asset/actor/sprite/default.png")
@export var portrait: Texture2D = load("res://asset/actor/portrait/default.png")
@export_multiline var description: String = "..."

# stats
@export var max_health: int = 10 ## Maximum value for [member health].
var health: int: ## When [member health] hits [code]0[/code], the actor is defeated.
	set(value):
		health_changed_by.emit(value - health)
		health = min(value, max_health)
		health_changed.emit(health)

@export var resistance: int ## Knockback received is decreased by this amount.
@export_range(0, 1, 0.01) var evasion: float ## Chance to evade an attack and move backward one tile.

# per-turn limits
@export var tiles_per_turn: int = 5 ## Maximum number of tiles traveled per turn. Also used to order actors' turns during battle.
@export var actions_per_turn: int = 1 ## Maximum number of actions taken per turn.
var tiles_traveled: int: ## The number of tiles traveled this turn.
	set(value):
		tiles_traveled = value
		end_turn_if_exhausted()
var actions_taken: int: ## The number of actions taken this turn.
	set(value):
		actions_taken = value
		end_turn_if_exhausted()

# actions
@export var actions: Array[Action] ## [Action]s available during battle.
@export var battlecry: Action ## Immediately started when the battle begins.

# effects
@export var attributes: Array
var status_effects: Array ## Active [StatusEffect]s. Add effects using [method add_status_effect].

# type affinities
@export_group("Affinities")
@export var weak_against: Array[Action.Type] ## Damage types whose damage is doubled.
@export var strong_against: Array[Action.Type] ## Damage types whose damage is halved.

# orientation
var position: Vector2i: ## The actor's current position.
	set(value): position = value; position_changed.emit(position)
var facing: Vector2i: ## The direction the actor is facing.
	set(value): facing = value; facing_changed.emit(facing)

# battle
var in_battle: bool: ## Whether the actor is in battle.
	set(value):
		in_battle = value
		if in_battle: battle_entered.emit()
		else: battle_exited.emit()
var path: Array[Dictionary] ## Contains all previous orientation states this turn.
var focusing: Action ## [Action] the actor is focusing on.

# node
var node: ActorNode



# movement

## Sets [member position] to [param to_pos] and [member facing] to the direction of motion.
func move(to_pos: Vector2i) -> void:
	var displacement: Vector2i = to_pos - position
	var axis: int = displacement.abs().max_axis_index()
	facing = (Vector2i.DOWN if axis else Vector2i.RIGHT) * signi(displacement[axis])
	position = to_pos


## Calculates knockback, adds it to [member position], and sets [member facing] reverse to the direction of motion.
func push(vector: Vector2i) -> void:
	facing = -vector
	position += calculate_knockback(vector)


## Decreases [param vector] by [member resistance] down to [constant Vector2i.ZERO].
func calculate_knockback(vector: Vector2i) -> Vector2i:
	vector.x = max(abs(vector.x) - resistance, 0) * sign(vector.x)
	vector.y = max(abs(vector.y) - resistance, 0) * sign(vector.y)
	return vector



# battle turns

## Starts the actor's turn.
func take_turn() -> void:
	actions_taken = 0
	tiles_traveled = -1
	extend_path()
	
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
	if action.needs_focus:
		focusing = action
		action.finished.connect(_clear_focus, CONNECT_ONE_SHOT)
		end_turn()
	
	await action.start()
	if not can_act(): end_turn()
	
	action_taken.emit()


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
	return actions_taken < actions_per_turn and not focusing


## Returns true if the actor has not exhausted [member tiles_per_turn].
func can_move() -> bool:
	return tiles_traveled < tiles_per_turn


## Ends the actor's turn if the actor cannot do anything else.
func end_turn_if_exhausted() -> void:
	if not (can_act() or can_move()):
		end_turn()



# action effects

func bear_action(action: Action) -> void:
	if randf() < evasion:
		evade(action.cause.facing)
	else:
		if action.strength:
			if action.type == Action.Type.HEALING: heal(action.strength)
			else: damage(action.strength, action.type)
		if action.knockback_type:
			push(Iso.rotate_grid_vector(action.knockback_vector, Game.direction_to_vector(action.cause.facing)))
		if action.status_effect:
			add_status_effect(action.status_effect.duplicate())


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

## Adds a [StatusEffect]. Active effects are stored in [member status_effects].
func add_status_effect(status_effect: StatusEffect) -> void:
	status_effect.target = self
	status_effect.start()
	
	status_effects.append(status_effect)
	status_effect_added.emit(status_effect)
	status_effect.ended.connect(remove_status_effect.bind(status_effect))


## Removes an [Effect]. Called automatically when an effect ends.
func remove_status_effect(status_effect: StatusEffect) -> void:
	status_effects.erase(status_effect)
	status_effect_removed.emit(status_effect)



# internal

func _init() -> void:
	_export_init.call_deferred()


func _export_init() -> void:
	health = max_health
	
	for i: int in actions.size():
		actions[i] = actions[i].duplicate()
		actions[i].cause = self


func _clear_focus() -> void:
	focusing = null


func _to_string() -> String:
	return name
