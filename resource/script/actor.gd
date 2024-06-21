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
@export var max_health: int = 10: ## Maximum value for [member health].
	get: return max_health + modifiers.max_health
var health: int: ## When [member health] hits [code]0[/code], the actor is defeated.
	set(value): health_changed_by.emit(value - health); health = min(value, max_health); health_changed.emit(health)
@export var resistance: int: ## Knockback received is decreased by this amount.
	get: return resistance + modifiers.resistance
@export_range(0, 1, 0.01) var evasion: float: ## Chance to evade an attack and move backward one tile.
	get: return evasion + modifiers.evasion

# per-turn limits
@export var tiles_per_turn: int = 5: ## Maximum number of tiles traveled per turn. Also used to order actors' turns during battle.
	get: return tiles_per_turn + modifiers.tiles_per_turn
@export var actions_per_turn: int = 1: ## Maximum number of actions taken per turn.
	get: return actions_per_turn + modifiers.actions_per_turn
var tiles_traveled: int: ## The number of tiles traveled this turn.
	set(value): tiles_traveled = value; end_turn_if_exhausted()
var actions_taken: int: ## The number of actions taken this turn.
	set(value): actions_taken = value; end_turn_if_exhausted()

# actions
@export var actions: Array[Action] ## [Action]s available during battle.
@export var battlecry: Action ## Immediately started when the battle begins.

# effects
@export var attributes: Array[Attribute]
var status_effects: Array ## Active [StatusEffect]s. Add effects using [method add_status_effect].
var modifiers: Dictionary = {
	"max_health": 0,
	"resistance": 0,
	"evasion": 0,
	"tiles_per_turn": 0,
	"actions_per_turn": 0,
}

# type affinities
@export_group("Affinities")
@export var weak_against: Array[Action.Type] ## Damage types whose damage is doubled.
@export var strong_against: Array[Action.Type] ## Damage types whose damage is halved.

# orientation
var position: Vector2i: ## The actor's current position in grid coordinates.
	set(value): position = value; position_changed.emit(position)
var facing: Vector2i: ## The direction the actor is facing in grid coordinates.
	set(value): facing = value; facing_changed.emit(facing)

# battle
var in_battle: bool: ## Whether the actor is in battle.
	set(value):
		in_battle = value
		if in_battle: battle_entered.emit()
		else: battle_exited.emit()
var path: Array[Dictionary] ## Contains all previous orientation states this turn.
var focusing: Action ## [Action] the actor is focusing on.
var will_evade_next: bool

# node
var node: ActorNode ## Node representation.



# movement

## Sets [member position] to [param to_pos] and [member facing] to the direction of motion.
func move(to_pos: Vector2i) -> void:
	var displacement: Vector2i = to_pos - position
	var axis: int = displacement.abs().max_axis_index()
	facing = (Vector2i.DOWN if axis else Vector2i.RIGHT) * signi(displacement[axis])
	position = to_pos



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


## Returns true if the actor has not exhausted [member actions_per_turn].
func can_act() -> bool:
	return actions_taken < actions_per_turn and not focusing


## Returns true if the actor has not exhausted [member tiles_per_turn].
func can_move() -> bool:
	return tiles_traveled < tiles_per_turn


## Returns true is the actor cannot do anything else.
func is_exhausted() -> bool:
	return not (can_act() or can_move())


## Ends the actor's turn if the actor cannot do anything else.
func end_turn_if_exhausted() -> void:
	if is_exhausted(): end_turn()


## Returns true if the actor cannot take their turn.
func is_incapacitated() -> bool:
	return (
		health <= 0 or
		not (can_act() or can_move())
	)



# actions

## Performs an [Action].
func take_action(action: Action) -> void:
	actions_taken += 1
	
	if action.needs_focus:
		focusing = action
		end_turn()
	
	await action.start()
	
	if not can_act():
		end_turn()


## Runs results of [param action].
func recieve_action(action: Action) -> void:
	if randf() < evasion:
		evade(action.cause.facing)
	else:
		if action.strength:
			if action.type == Action.Type.HEALING: heal(action.strength)
			else: damage(action.strength, action.type)
		if action.knockback_type:
			var vector: Vector2i = Iso.rotate_grid_vector(action.knockback_vector, action.cause.facing)
			facing = -vector
			position += calculate_knockback(vector)
		if action.status_effect:
			add_status_effect(action.status_effect.duplicate())


## Modifies [param amount] according to the actor's type affinities,
## then subtracts it from [member health].
func damage(amount: int, type: Action.Type = Action.Type.NONE) -> void:
	health -= calculate_damage(amount, type)
	if health <= 0: defeated.emit()


## Increases [member health] by [param amount].
func heal(amount: int) -> void:
	health += amount


## Evades an attack.
func evade(direction: Vector2i) -> void:
	facing = -direction
	position += direction
	decide_next_evade()



# pre-calculations

## Decreases [param vector] by [member resistance] down to [constant Vector2i.ZERO].
func calculate_knockback(vector: Vector2i) -> Vector2i:
	vector.x = max(abs(vector.x) - resistance, 0) * sign(vector.x)
	vector.y = max(abs(vector.y) - resistance, 0) * sign(vector.y)
	return vector


func calculate_damage(amount: int, type: Action.Type) -> int:
	if weak_against.has(type): return amount * 2
	if strong_against.has(type): return amount / 2
	return amount


func decide_next_evade() -> void:
	will_evade_next = randf() > evasion



# status effects

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



# path

## Records the current position and direction to [member path].
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



# internal

func _init() -> void:
	_export_init.call_deferred()


func _export_init() -> void:
	health = max_health
	
	for i: int in actions.size():
		actions[i] = actions[i].duplicate()
		actions[i].cause = self
		actions[i].finished.connect(emit_signal.bind("action_taken"))
	
	Battle.started.connect(_on_battle_started)


func _on_battle_started() -> void:
	decide_next_evade()


func _to_string() -> String:
	return name
