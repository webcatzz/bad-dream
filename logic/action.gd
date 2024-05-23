class_name Action extends Resource


signal delay_changed(value: int)
signal triggered

enum Type {NONE, FERVENT, BENTHIC, WHORLED, HOLY, PROFANE, HEALING}
enum Shape {SQUARE, CIRCLE}
enum Knockback {LINE, CIRCLE}

@export var name: String = "Action"
@export var strength: int = 1
@export var type: Type

@export var delay: int
@export var ends_turn: bool = false

@export_group("Splash", "splash_")
@export var splash_shape: Shape = Shape.SQUARE
@export var splash_size: int = 1
@export var splash_offset: Vector2i = Vector2i(0, 1)

@export_group("Knockback", "knockback_")
@export var knockback_shape: Knockback
@export var knockback_strength: int
@export var knockback_point: Vector2i

@export_group("Effects")
@export var effect: Effect

var cause: Actor


func start() -> void:
	cause.actions_taken += 1
	if ends_turn: cause.end_turn()
	
	if delay: Battle.turn_ended.connect(_decrement_delay)
	else: triggered.emit()


# Decrements [member delay]. When it becomes 0, the action triggers.
func _decrement_delay() -> void:
	delay -= 1
	if delay == 0:
		Battle.turn_ended.disconnect(_decrement_delay)
		triggered.emit()


func affect(actor: Actor) -> void:
	if type == Type.HEALING: actor.heal(strength)
	else: actor.damage(strength, type)
	
	if knockback_strength: knockback(actor)
	if effect: actor.add_effect(effect.duplicate())


func knockback(actor: Actor) -> void:
	var strength: int = knockback_strength - actor.resistance
	
	if strength > 0: match knockback_shape:
		Knockback.LINE: actor.position += cause.facing * strength
