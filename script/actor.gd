class_name Actor extends Character


# key stats
signal will_changed(by: int)
signal stamina_changed
# conditions
signal condition_added(condition: Condition)
signal condition_removed(condition: Condition)
# orientation
signal reoriented

@export var max_will: int = 1
@export var will: int = 1

@export var max_stamina: int = 1
@export var stamina: int = 1

@export var attack: int
@export var defense: int
@export_range(0, 1, 0.05) var evasion: float

@export var traits: Array[Trait.Type]
var conditions: Array[Condition]

@export var actions: Array[Action]
@export var limit_break: LimitBreak

var position: Vector2i
var facing: Vector2i = Vector2i(0, 1)
var path: Array[Dictionary]

var node: Node2D



# will

func add_will(num: int) -> void:
	will += num
	will_changed.emit(num)



# conditions

func add_condition(condition: Condition) -> void:
	conditions.append(condition)
	condition_added.emit(condition)


func remove_condition(condition: Condition) -> void:
	conditions.erase(condition)
	condition_removed.emit(condition)



# orientation

func move_to(tile: Vector2i) -> void:
	facing = calc_facing(tile - position)
	position = tile
	reoriented.emit()


func move_by(motion: Vector2i) -> void:
	facing = calc_facing(motion)
	position += motion
	reoriented.emit()


func add_to_path() -> void:
	stamina -= 1
	path.append({
		"position": position,
		"facing": facing
	})


func unpath() -> void:
	var point: Dictionary = path.pop_back()
	position = point.position
	facing = point.facing
	reoriented.emit()


# actions

func take_action(action: Action) -> void:
	var accuracy: float = float(will) / max_will * 0.5 + 0.5
	if randf() > accuracy: return


func recieve_action(action: Action) -> void:
	if randf() < evasion: return



# checks + calculations

func can_move() -> bool:
	return stamina > 0


func calc_facing(motion: Vector2i) -> Vector2i:
	var axis: int = motion.abs().max_axis_index()
	return (Vector2i.DOWN if axis else Vector2i.RIGHT) * signi(motion[axis])
