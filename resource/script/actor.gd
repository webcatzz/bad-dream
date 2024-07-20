class_name Actor extends Resource


# orientation
signal position_changed(value: Vector2i)
signal facing_changed(value: Vector2i)
# stats
signal health_changed(value: int)
signal health_changed_by(value: int)
signal evaded(successful: bool)
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

# stats
@export var max_health: int = 10: ## Maximum value for [member health].
	get: return maxf(max_health + modifiers.max_health, 0)
var health: int = 1: ## When [member health] hits [code]0[/code], the actor is defeated.
	set(value): health_changed_by.emit(value - health); health = min(value, max_health); health_changed.emit(health)
@export var defense: int: ## Damage taken is decreased by this amount.
	get: return maxf(defense + modifiers.defense, 0)
@export var resistance: int: ## Knockback received is decreased by this amount.
	get: return maxf(resistance + modifiers.resistance, 0)
@export_range(0, 1, 0.01) var evasion: float: ## Chance to evade an attack and move backward one tile.
	get: return clampf(evasion + modifiers.evasion, 0, 1)

# per-turn limits
@export var tiles_per_turn: int = 5: ## Maximum number of tiles traveled per turn. Also used to order actors' turns during battle.
	get: return maxf(tiles_per_turn + modifiers.tiles_per_turn, 0)
@export var actions_per_turn: int = 1: ## Maximum number of actions taken per turn.
	get: return maxf(actions_per_turn + modifiers.actions_per_turn, 0)
var tiles_traveled: int ## The number of tiles traveled this turn.
var actions_taken: int ## The number of actions taken this turn.

# actions
@export var actions: Array[Action] ## [Action]s available during battle.
var current_action: Action ## [Action] the actor is currently taking.
var current_splash: Splash

# effects
@export var attributes: Array[Attribute.Type]
var status_effects: Array ## Active [StatusEffect]s. Add effects using [method add_status_effect].
var modifiers: Dictionary = {
	"max_health": 0,
	"resistance": 0,
	"evasion": 0,
	"tiles_per_turn": 0,
	"actions_per_turn": 0,
	"defense": 0,
}

# sprite
@export_group("Appearance")
@export var sprite: SpriteFrames = load("res://asset/actor/sprite/default.tres")
@export var sprite_offset: Vector2i = Vector2i(0, -24)
@export var portrait: Texture2D = load("res://asset/actor/portrait/default.png")
@export_multiline var description: String = "..."

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

# node
var node: ActorNode ## Node representation.



# movement

## Moves to [param pos]. Updates [member facing] to the direction of motion.
func move_to(pos: Vector2i) -> void:
	facing = calculate_facing(pos - position)
	position = pos


## Moves by [param vector]. Updates [member facing] to the direction of motion.
func move(vector: Vector2i) -> void:
	facing = calculate_facing(vector)
	position += vector


func calculate_facing(motion: Vector2i) -> Vector2i:
	var axis: int = motion.abs().max_axis_index()
	return (Vector2i.DOWN if axis else Vector2i.RIGHT) * signi(motion[axis])



# battle turns

## Starts the actor's turn.
func take_turn() -> void:
	actions_taken = 0
	tiles_traveled = 0
	turn_started.emit()
	
	if can_take_turn():
		await _take_turn()
	else:
		await Game.get_tree().create_timer(0.5).timeout
		end_turn()


func _take_turn() -> void:
	node.take_turn()
	await turn_ended


## Ends the actor's turn.
func end_turn() -> void:
	path.clear()
	turn_ended.emit()


## Ends the actor's turn if the actor cannot do anything else.
func end_turn_if_exhausted() -> void:
	if is_exhausted(): end_turn()



# actions

## Performs an [Action].
func take_action(action: Action) -> void:
	actions_taken += 1
	current_action = action
	
	await action.start(self)
	
	if not can_act():
		end_turn()


## Runs results of [param action].
func recieve_action(action: Action, cause: Actor) -> void:
	if randf() < evasion and try_evade(cause.facing): return
	
	if action.strength:
		if action.type == Action.Type.HEALING: heal(action.strength)
		else:
			if cause.facing == facing: damage(action.strength * 1.1, action.type)
			elif cause.facing == -facing: damage(action.strength * 0.9, action.type)
			else: damage(action.strength, action.type)
	if action.knockback_type:
		var vector: Vector2i = Iso.rotate_grid_vector(action.knockback_vector, cause.facing)
		facing = -calculate_facing(vector)
		position += calculate_knockback(vector)
	if action.status_effect:
		add_status_effect(action.status_effect)


## Modifies [param amount] according to the actor's type affinities,
## then subtracts it from [member health].
func damage(amount: int, type: Action.Type = Action.Type.NONE) -> void:
	health -= max(calculate_damage(amount, type) - modifiers.defense, 0)
	if health <= 0: defeated.emit()


func die_badly() -> void:
	health = 0
	defeated.emit()


## Increases [member health] by [param amount].
func heal(amount: int) -> void:
	health += amount
 

## Evades an attack.
func try_evade(direction: Vector2i) -> bool:
	var successful: bool = (
		Battle.field.is_point_travellable(position + direction)
		and not has_status_effect(StatusEffect.Type.SLEEP)
	)
	
	if successful:
		facing = -direction
		position += direction
	
	evaded.emit(successful)
	return successful


## Ends the current turn and guards until the next turn.
func guard() -> void:
	end_turn()
	var guard: StatusEffect = StatusEffect.new()
	guard.type = StatusEffect.Type.GUARD
	turn_started.connect(guard.end.bind(self))
	add_status_effect(guard)



# inventory

func use_item(item: Item) -> void:
	actions_taken += 1
	current_action = item.action
	
	Data.remove_item(item.name)
	await item.use(self)
	
	if not can_act():
		end_turn()



# checks

## Returns true if the actor has not exhausted [member actions_per_turn].
func can_act() -> bool:
	return actions_taken < actions_per_turn and actions


## Returns true if the actor has not exhausted [member tiles_per_turn].
func can_move() -> bool:
	return tiles_traveled < tiles_per_turn


## Returns true is the actor cannot do anything for the rest of their turn.
func is_exhausted() -> bool:
	return not (can_act() or can_move())


## Returns true if the actor's health is 0 or less.
func is_defeated() -> bool:
	return health <= 0


## Returns true if the actor cannot take their turn.
func can_take_turn() -> bool:
	return not (is_defeated() or is_exhausted() or current_action)



# pre-calculations

## Decreases [param vector] by [member resistance] down to [constant Vector2i.ZERO].
func calculate_knockback(vector: Vector2i) -> Vector2i:
	vector.x = max(abs(vector.x) - resistance, 0) * sign(vector.x)
	vector.y = max(abs(vector.y) - resistance, 0) * sign(vector.y)
	return Battle.field.collide_ray(position, vector)


func calculate_damage(amount: int, type: Action.Type) -> int:
	if weak_against.has(type): return amount * 2
	if strong_against.has(type): return amount / 2
	return amount



# status effects

## Adds a [StatusEffect]. Active effects are stored in [member status_effects].
func add_status_effect(status_effect: StatusEffect) -> void:
	status_effect.start(self)
	
	status_effects.append(status_effect)
	status_effect_added.emit(status_effect)


## Removes an [Effect]. Called automatically when an effect ends.
func remove_status_effect(status_effect: StatusEffect) -> void:
	status_effects.erase(status_effect)
	status_effect_removed.emit(status_effect)


func has_status_effect(type: StatusEffect.Type) -> bool:
	for status_effect: StatusEffect in status_effects:
		if status_effect.type == type:
			return true
	return false



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
	action_taken.connect(_on_action_taken)


func _export_init() -> void:
	health = max_health
	
	for attribute: Attribute.Type in attributes:
		Attribute.add(attribute, self)


func _on_action_taken() -> void:
	current_splash.finish()
	current_action = null
	current_splash = null


func _to_string() -> String:
	return name
