class_name Actor extends Character


# key stats
signal will_changed(by: int)
signal stamina_changed
# modifiers
signal trait_removed(type: Trait.Type)
signal condition_added(condition: Condition)
signal condition_removed(condition: Condition)
# orientation
signal reoriented

# key stats
@export var will: int = 1
@export var max_will: int = 1
@export var stamina: int = 1
@export var max_stamina: int = 1
# stats
@export var attack: int
@export var defense: int
@export_range(0, 1, 0.05) var evasion: float
# modifiers
@export var traits: Array[Trait.Type]
var conditions: Array[Condition]
# actions
@export var actions: Array[Action]
@export_group("Limit break", "limit_break_")
@export var limit_break_action: Action
@export var limit_break_max: int
@export var limit_break_progress: int
# orientation
var position: Vector2i
var facing: Vector2i = Vector2i(0, 1)
var path: Array[Dictionary]
# node
var node: ActorNode



# movement

func set_position(tile: Vector2i) -> void:
	position = tile
	reoriented.emit()


func move_to(tile: Vector2i) -> void:
	facing = calc_facing(tile - position)
	position = tile
	reoriented.emit()


func move_by(motion: Vector2i) -> void:
	facing = calc_facing(motion)
	position += motion
	reoriented.emit()



# path

func add_to_path() -> void:
	stamina -= 1
	path.append({
		"position": position,
		"facing": facing
	})
	reoriented.emit()


func unpath() -> void:
	stamina += 1
	var point: Dictionary = path.pop_back()
	position = point.position
	facing = point.facing
	reoriented.emit()



# will

func add_will(num: int) -> void:
	will += num
	will_changed.emit(num)



# taking actions

func take_action(action: Action) -> void:
	pass



# recieving actions

func recieve_action(action: Action) -> void:
	pass


func recieve_damage(num: int) -> void:
	add_will(num - defense)



# modifiers

func add_trait(type: Trait.Type) -> void:
	Trait.apply(type, self)
	traits.append(type)


func remove_trait(type: Trait.Type) -> void:
	Trait.unapply(type, self)
	traits.erase(type)


func add_condition(condition: Condition) -> void:
	condition.actor = self
	condition.apply()
	conditions.append(condition)


func remove_condition(condition: Condition) -> void:
	condition.unapply()
	conditions.erase(condition)



# checks + calculations

func can_move() -> bool:
	return stamina > 0


func can_take_action(action: Action) -> bool:
	return action.cost <= stamina


func calc_facing(motion: Vector2i) -> Vector2i:
	var axis: int = motion.abs().max_axis_index()
	return (Vector2i.DOWN if axis else Vector2i.RIGHT) * signi(motion[axis])
