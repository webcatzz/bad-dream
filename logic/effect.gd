class_name Effect extends Resource


signal ended

enum Type {
	BURN,
	POISON,
	VANISH,
}

@export var type: Type
## The effect lasts for this many turns.
## This value is decremented every time the [member target] ends their turn.
## When it hits 0, the effect ends.
@export var duration: int = 1
@export var strength: int = 1

## The [Actor] this effect targets.
var target: Actor


func start() -> void:
	target.turn_ended.connect(_decrement_duration)
	
	match type:
		Type.BURN:
			target.action_taken.connect(target.damage.bind(1, Action.Type.FIRE), CONNECT_REFERENCE_COUNTED)
		Type.POISON:
			target.turn_ended.connect(target.damage.bind(1, Action.Type.SPIRAL), CONNECT_REFERENCE_COUNTED)
		Type.VANISH:
			pass


func _decrement_duration() -> void:
	duration -= 1
	if duration == 0: end()


func end() -> void:
	match type:
		Type.BURN:
			target.action_taken.disconnect(target.damage)
		Type.POISON:
			target.turn_ended.disconnect(target.damage)
		Type.VANISH:
			pass
	
	ended.emit()
