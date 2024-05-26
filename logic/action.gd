class_name Action extends Resource


signal delay_changed(value: int)
signal triggered

enum Type {NONE, FIRE, OCEAN, SPIRAL, HOLY, PROFANE, HEALING}
enum Shape {SQUARE, CIRCLE, PATH}
enum Knockback {LINE, CIRCLE}

@export var name: String = "Action"
@export_multiline var description: String

@export var strength: int = 1
@export var type: Type
@export var delay: int
@export var ends_turn: bool = false
@export var effect: Effect

@export_group("Shape", "shape_")
@export var shape_type: Shape
@export var shape_size: int = 1
@export var shape_offset: Vector2i = Vector2i(0, 1)

@export_group("Knockback", "knockback_")
@export var knockback_shape: Knockback
@export var knockback_strength: int
@export var knockback_point: Vector2i

var cause: Actor


func start() -> void:
	cause.actions_taken += 1
	if ends_turn: cause.end_turn()
	
	if delay: Battle.turn_ended.connect(_decrement_delay.unbind(1))
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


func get_bitshape() -> BitShape:
	var bitshape: BitShape = BitShape.new()
	bitshape.offset = shape_offset
	
	match shape_type:
		Shape.SQUARE:
			var size: Vector2i = Vector2i(shape_size, shape_size)
			bitshape.create(size)
			bitshape.set_bit_rect(Rect2i(Vector2.ZERO, size), true)
			bitshape.offset -= size / 2
		
		Shape.PATH:
			var path: Dictionary = get_path_data()
			var grow_margins: Vector2i = Vector2i(shape_size, shape_size)
			path.bounds = path.bounds.grow(shape_size)
			
			# creating bitmap
			bitshape.create(path.bounds.size + Vector2i.ONE)
			for point: Vector2i in path.points:
				bitshape.set_bit_rect(
					Rect2i(point - path.bounds.position - grow_margins, grow_margins * 2 + Vector2i.ONE),
					true
				)
			bitshape.offset -= path.bounds.size + Vector2i.LEFT
	
	ResourceSaver.save(bitshape, "res://bit_shape.tres")
	return bitshape



func get_path_data() -> Dictionary:
	var path: Array[Dictionary] = cause.node.path
	var points: Array[Vector2i] = []
	points.resize(path.size() - 1)
	var bounds: Rect2i = Rect2i(Iso.to_cart(path[0].position), Vector2i.ZERO)
	
	for i: int in path.size() - 1:
		points[i] = Iso.to_cart(path[i].position)
		bounds = bounds.expand(points[i])
	
	return {
		"points": points,
		"bounds": bounds,
	}
