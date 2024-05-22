class_name Actor extends Resource


signal position_changed(value: Vector2)
signal facing_changed(value: Vector2)

# battle
signal health_changed(value: int)
signal health_changed_by(value: int)
signal effect_added(type: Action.Effect, duration: int)
signal effect_removed(type: Action.Effect)
signal turn_started
signal turn_ended
signal defeated


@export var name: String = "Actor"

# appearance
@export var sprite: Texture2D = load("res://asset/sprite/default.png")
@export var portrait: Texture2D = load("res://asset/portrait/default.png")
@export_multiline var description: String

# stats
@export_group("Stats")
## The actor's maximum health. [member health] cannot go above this value.
@export var max_health: int = 10
## The actor's current health. When it hits [code]0[/code], the actor is defeated.
var health: int:
	set(value):
		health_changed_by.emit(value - health)
		health = value
		health_changed.emit(health)
## Knockback dealt to this actor is decreased by this amount.
@export var resistance: int

## The maximum number of tiles the actor can travel in a single turn. Also used for battle order.
@export var tiles_per_turn: int = 1
## The maximum number of actions the actor can take in a single turn.
@export var actions_per_turn: int = 1
## The number of tiles the actor has traveled this turn.
var tiles_traveled: int = 0
## The number of actions the actor has taken this turn.
var actions_taken: int = 0

# type affinities
@export_group("Type affinities")
## The actor recieves doubled damage from these damage types.
@export var weak_against: Array[Action.Type]
## The actor recieves halved damage from these damage types.
@export var strong_against: Array[Action.Type]

# actions
@export_group("Actions")
## A list of the actions the actor can take during battle.
@export var actions: Array[Action]
## Immediately started when the battle begins.
@export var battlecry: Action
## The action the actor is focusing on.
var focusing: Action

# orientation
## The actor's current position.
var position: Vector2i:
	set(value):
		position = value
		position_changed.emit(position)
## The direction the actor is facing. One of the Iso constants.
var facing: Vector2i = Iso.VECTOR:
	set(value):
		facing = value
		facing_changed.emit(facing)

var effects: Dictionary

var node: ActorNode


func _init() -> void:
	turn_started.connect(decrement_effects)
	(func(): health = max_health).call_deferred() # once export properties are initialized


## Sets [member position] to [param new_pos] and sets [member facing] to the direction of motion.
func move(new_pos: Vector2i) -> void:
	facing = Iso.get_direction(new_pos - position)
	position = new_pos


# battle

## Starts the actor's turn.
func take_turn() -> void:
	actions_taken = 0
	tiles_traveled = 0
	turn_started.emit()
	node.take_turn()
	await turn_ended

## Ends the actor's turn.
func end_turn() -> void:
	turn_ended.emit()


func can_act() -> bool:
	return actions_taken < actions_per_turn

func can_move() -> bool:
	return tiles_traveled < tiles_per_turn

func is_turn_exhausted() -> bool:
	return !(can_act() or can_move())







## Modifies [param amount] according to the actor's type affinities,
## then subtracts it from [member health].
func damage(amount: int, type: Action.Type) -> void:
	if weak_against.has(type): amount *= 2
	elif strong_against.has(type): amount /= 2
	health -= amount
	if health <= 0: defeated.emit()

## Increases [member health] by [param amount].
func heal(amount: int) -> void:
	health += amount


func add_effect(type: Action.Effect, duration: int) -> void:
	if effects.has(type) and duration <= effects[type]: return
	effects[type] = duration
	effect_added.emit(type, duration)


func decrement_effects() -> void:
	for effect: String in effects:
		effects[effect] -= 1
		await turn_ended
		if effects[effect] == 0:
			effects.erase(effect)
			effect_removed.emit(effect)



# string conversion

func _to_string() -> String:
	return name
