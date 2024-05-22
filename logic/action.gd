class_name Action extends Resource


signal delay_changed(value: int)
signal triggered

enum Type {NONE, FERVENT, BENTHIC, WHORLED, HOLY, PROFANE, HEALING}
enum Shape {SQUARE, CIRCLE}
enum Knockback {LINE, CIRCLE}
enum Effect {BURNING, POISONED}

@export var name: String = "Action"
@export var strength: int
@export var type: Type

@export var delay: int
@export var ends_turn: bool = false

@export_group("Splash", "splash_")
@export var splash_shape: Shape = Shape.SQUARE
@export var splash_size: int = 1
@export var splash_offset: Vector2i = Vector2i(1, 0)

@export_group("Knockback", "knockback_")
@export var knockback_shape: Knockback
@export var knockback_strength: int
@export var knockback_point: Vector2i

@export_group("Effect", "effect_")
@export var effect_type: Effect
@export var effect_duration: int

var cause: Actor


## Decrements [member delay] at the end of every turn.
func start() -> void:
	cause.actions_taken += 1
	if ends_turn or cause.is_turn_exhausted():
		cause.end_turn()
	
	if delay: Battle.turn_ended.connect(decrement_delay)
	else: trigger()

## Decrements [member delay]. If it is [code]0[/code], calls [method trigger].
func decrement_delay() -> void:
	delay -= 1
	
	if delay <= 0:
		Battle.turn_ended.disconnect(decrement_delay)
		trigger()

func trigger() -> void:
	triggered.emit()

## Affects an actor.
func affect(actor: Actor) -> void:
	if type == Type.HEALING: actor.heal(strength)
	else: actor.damage(strength, type)
	
	if knockback_strength: knockback(actor)
	if effect_duration: actor.add_effect(effect_type, effect_duration)


func knockback(actor: Actor) -> void:
	var strength: int = knockback_strength - actor.resistance
	
	if strength > 0: match knockback_shape:
		Knockback.LINE: actor.position += cause.facing * strength

func run_status() -> void:
	pass

func get_status_string() -> String:
	return Effect.keys()[effect_type]
