class_name Action extends Resource

signal delay_changed(value: int)
signal delay_ended

enum Type {NORMAL, FERVENT, BENTHIC, WHORLED, HOLY, PROFANE, HEALING}
enum Shape {SQUARE, CIRCLE}
enum Knockback {LINE, CIRCLE}
enum Effect {ON_FIRE, POISONED}

@export var name: String
@export var strength: int
@export var type: Type
@export var delay: int

@export_group("Splash", "splash_")
@export var splash_shape: Shape
@export var splash_size: int = 1
@export var splash_offset: Vector2i

@export_group("Knockback", "knockback_")
@export var knockback_shape: Knockback
@export var knockback_strength: int
@export var knockback_point: Vector2i

@export_group("Effect", "effect_")
@export var effect_type: Effect
@export var effect_duration: int


func start_counting(): Battle.turn_ended.connect(decrement_delay)

func decrement_delay(): delay -= 1


func calculate_knockback(pos: Vector2i, resist: int) -> Vector2i:
	var strength: int = knockback_strength - resist
	if strength > 0: match knockback_shape:
		Knockback.LINE: pos += Iso.VECTOR * knockback_point * strength
		Knockback.CIRCLE:
			var offset: Vector2i = pos - knockback_point
			# todo: code area knockback
	return pos


func run_status():
	pass


func get_node() -> Splash: return Splash.new(self)

func get_status_string() -> String: return Effect.keys()[effect_type]
