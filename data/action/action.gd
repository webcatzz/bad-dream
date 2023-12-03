class_name Action extends Resource

enum Type {BLAZE, BENTHIC, HOLY, PROFANE}

@export var damage: int
@export var delay: int

@export_group("Splash", "splash_")
@export_enum("Square", "Circle") var splash_shape: String = "Square"
@export var splash_size: int = 1
@export var splash_offset: Vector2

@export_group("Knockback", "knockback_")
@export_enum("Line", "Circle") var knockback_shape: String = "Line"
@export var knockback_strength: int
@export var knockback_point: Vector2



func calculate_knockback(pos: Vector2) -> Vector2:
	if knockback_strength: match knockback_shape:
		"Line": pos += Vector2(16, 8) * knockback_point * knockback_strength
		"Circle":
			var offset: Vector2 = pos - knockback_point
			# todo: code area knockback
	return pos
