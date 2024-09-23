class_name Condition extends Resource


enum Type {
	BURN,
	DOOM,
	GUARD,
	SLEEP,
	SPEED,
}

@export var type: Type
@export var duration: int = 1
@export var strength: int = 1

var actor: Actor
var duration_left: int


func apply() -> void:
	duration_left = duration
	
	match type:
		Type.SPEED:
			actor.reoriented.connect(_speed_listener)
		Type.BURN:
			actor.action_sent.connect(actor.damage.bind(1))


func unapply() -> void:
	match type:
		Type.SPEED:
			actor.reoriented.disconnect(_speed_listener)
		Type.BURN:
			actor.action_sent.disconnect(actor.damage.bind(1))


static func from(type: Type, duration: int, strength: int = 1) -> Condition:
	var condition: Condition = Condition.new()
	condition.type = type
	condition.duration = duration
	condition.strength = strength
	return condition



# getters

func name() -> String:
	return Type.keys()[type].capitalize()


func color() -> Color:
	match type:
		Type.BURN: return Palette.RED
		_: return Palette.PANEL_0



# internal

func _speed_listener() -> void:
	pass
