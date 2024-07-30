class_name Actor extends Character


# key stats
signal will_changed(by: int)
signal stamina_changed
# conditions
signal condition_added(condition: Condition)
signal condition_removed(condition: Condition)
# orientation
signal position_changed
signal facing_changed
# turns
signal turn_started
signal turn_ended

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

var position: Vector2i:
	set(value):
		position = value
		position_changed.emit()
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
	position = tile


func move_by(vector: Vector2i) -> void:
	position += vector


func extend_path() -> void:
	path.append({
		"position": position,
		"facing": facing
	})


func backtrack_path() -> void:
	path.resize(path.size() - 1)



# turns

func start_turn() -> void:
	stamina = max_stamina
	
	turn_started.emit()


func end_turn() -> void:
	turn_ended.emit()



# actions

func take_action(action: Action) -> void:
	var accuracy: float = float(will) / max_will * 0.5 + 0.5
	if randf() > accuracy: return


func recieve_action(action: Action) -> void:
	if randf() < evasion: return
