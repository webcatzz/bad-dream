class_name Actor extends Resource

# health
signal health_changed(value: int)
signal health_changed_by(value: int)
# orientation
signal position_changed(value: Vector2)
signal facing_changed(value: Vector2)
# battle
signal turn_started
signal turn_ended
signal defeated

@export var name: String = "Actor"
# flavor
@export var sprite: Texture2D = load("res://asset/sprite/default.png")
@export var portrait: Texture2D = load("res://asset/portrait/default.png")
@export_multiline var description: String
@export var controlled: bool
# stats
@export var max_health: int = 1
@export var speed: int = 1
@export var weak_against: Array[Action.Type]
@export var strong_against: Array[Action.Type]
@export var knockback_resist: int
# runtime
var health: int = max_health
var position: Vector2i
var facing: Vector2i
var order: int
var node: ActorNode


func take_turn():
	turn_started.emit()
	if controlled:
		node.take_turn()
		await turn_ended
	else:
		await UI.get_tree().create_timer(0.5).timeout
		turn_ended.emit()


func move(new_pos: Vector2i):
	facing = Iso.get_direction(new_pos - position)
	position = new_pos
	position_changed.emit(position)
	facing_changed.emit(facing)


func damage(amount: int, type: Action.Type):
	if weak_against.has(type): amount *= 2
	elif strong_against.has(type): amount /= 2
	health -= amount
	health_changed.emit(health)
	health_changed_by.emit(amount)
	if health <= 0: defeated.emit()


func heal(amount: int):
	health += amount
	health_changed.emit(health)
	health_changed_by.emit(amount)


func create_node() -> Node2D:
	var node = load("res://scene/actor.tscn").instantiate()
	node.data = self
	return node


func _to_string(): return name + "(" + str(health) + "/" + str(max_health) + ")"
