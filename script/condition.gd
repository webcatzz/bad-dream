class_name Condition extends Resource


enum Type {
	BURN,
	DOOM,
	GUARD,
	SLEEP,
	SPEED,
	
	RAGE,
	ADRENALINE,
	ALERT,
}

@export var type: Type
@export var duration: int = 1
@export var strength: int = 1

var actor: Actor
var duration_left: int


func apply() -> void:
	duration_left = duration
	
	match type:
		Type.BURN:
			actor.action_sent.connect(actor.damage.bind(1))
		Type.RAGE:
			actor.attack += strength
		Type.ADRENALINE:
			actor.defense += strength
		Type.ALERT:
			actor.evasion += 0.25 * strength


func unapply() -> void:
	match type:
		Type.BURN:
			actor.action_sent.disconnect(actor.damage.bind(1))
		Type.RAGE:
			actor.attack -= strength
		Type.ADRENALINE:
			actor.defense -= strength
		Type.ALERT:
			actor.evasion -= 0.25 * strength


static func from(type: Type, duration: int, strength: int = 1) -> Condition:
	var condition: Condition = Condition.new()
	condition.type = type
	condition.duration = duration
	condition.strength = strength
	return condition



# getters

func name() -> String:
	return Type.keys()[type].capitalize()


func icon() -> Texture2D:
	return load("res://asset/modifier/%s.png" % name())


func color() -> Color:
	match type:
		Type.BURN: return Palette.RED
		_: return Palette.PANEL_0


func vfx() -> Node:
	match type:
		Type.BURN: return load("res://node/vfx/burn.tscn").instantiate()
		_: return null
