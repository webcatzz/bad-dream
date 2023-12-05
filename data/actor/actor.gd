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
# effects
signal effect_added(type: Action.Effect, duration: int)
signal effect_removed(type: Action.Effect)

@export var name: String = "Actor"
# flavor
@export var sprite: Texture2D = load("res://asset/sprite/default.png")
@export var portrait: Texture2D = load("res://asset/portrait/default.png")
@export_multiline var description: String
@export var controlled: bool
# stats
@export var max_health: int = 10
@export var speed: int = 1
@export var weak_against: Array[Action.Type]
@export var strong_against: Array[Action.Type]
@export var knockback_resist: int
@export var actions: Array[Action]
# runtime
var health: int = max_health:
	set(value): health_changed_by.emit(value - health); health = value; health_changed.emit(health)
var position: Vector2i:
	set(value): position = value; position_changed.emit(position)
var facing: Vector2i:
	set(value): facing = value; facing_changed.emit(facing)
var effects: Dictionary
var order: int
var node: ActorNode


func _init():
	turn_started.connect(decrement_effects)


func take_turn():
	turn_started.emit()
	if controlled:
		node.take_turn()
		await turn_ended
	else:
		await UI.get_tree().create_timer(0.5).timeout
		turn_ended.emit()


func move(new_pos: Vector2i, face_back: bool = false):
	facing = Iso.get_direction(new_pos - position if not face_back else position - new_pos)
	position = new_pos


func affect(action: Action):
	if action.type == action.Type.HEALING: heal(action.strength)
	else: damage(action.strength, action.type)
	if action.knockback_strength: move(action.calculate_knockback(position, knockback_resist), true)
	if action.effect_duration: add_effect(action.effect_type, action.effect_duration)


func damage(amount: int, type: Action.Type):
	if weak_against.has(type): amount *= 2
	elif strong_against.has(type): amount /= 2
	health -= amount
	if health <= 0: defeated.emit()


func heal(amount: int):
	health += amount


func add_effect(type: Action.Effect, duration: int):
	if effects.has(type) and duration <= effects[type]: return
	effects[type] = duration
	effect_added.emit(type, duration)


func decrement_effects():
	for effect in effects:
		effects[effect] -= 1
		await turn_ended
		if effects[effect] == 0:
			effects.erase(effect)
			effect_removed.emit(effect)
