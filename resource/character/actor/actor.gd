class_name Actor extends Character


# key stats
signal will_changed(by: int)
signal stamina_changed
signal defeated
# modifiers
signal trait_removed(type: Trait.Type)
signal condition_added(condition: Condition)
signal condition_removed(condition: Condition)
# actions
signal action_sent
signal missed
signal evaded
signal evade_failed
# orientation
signal reoriented

# key stats
@export var will: int = 1
@export var max_will: int = 1
@export var stamina: int = 1:
	set(value): stamina = value; stamina_changed.emit()
@export var max_stamina: int = 1
# stats
var attack: int
var defense: int
var evasion: float
# modifiers
@export var traits: Array[Trait.Type]
var conditions: Array[Condition]
# actions
@export var actions: Array[Action]
var acted_this_phase: bool = false
@export_group("Limit break", "limit_break_")
@export var limit_break_action: Action
@export var limit_break_max: int
@export var limit_break_progress: int
# weaknesses
@export_group("Type affinity")
@export var type_weak: Array[Action.Type]
@export var type_strong: Array[Action.Type]
# orientation
var position: Vector2i
var facing: Vector2i = Vector2i(0, 1)
var path: Array[Dictionary]
# pocket
var pocket: Item



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


func path_to(tile: Vector2i) -> void:
	await follow_path(Game.grid.get_id_path(position, tile))


func follow_path(path: Array[Vector2i]) -> void:
	for tile: Vector2i in path:
		move_to(tile)
		await Game.get_tree().create_timer(0.1).timeout



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
	will = clampi(will + num, 0, max_will)
	will_changed.emit(num)



# sending actions

func send_action(action: Action) -> void:
	if randf() <= accuracy():
		var affected: Array[Actor] = Game.grid.collide_action(action, self)
		
		for actor: Actor in affected:
			actor.recieve_action(action, self)
	
	else:
		missed.emit()
	
	action_sent.emit()
	stamina = 0
	acted_this_phase = true


func guard() -> void:
	add_condition(Condition.from(Condition.Type.GUARD, 1))
	stamina = 0



# recieving actions

func recieve_action(action: Action, cause: Actor) -> void:
	if try_evade(cause.facing): return
	
	if action.strength:
		if action.type == Action.Type.HEALING:
			heal(action.strength)
		else:
			damage(action.strength + cause.traits.count(Trait.Type.STRENGTH), action.type)
	
	if action.knockback:
		var vector: Vector2i = Iso.rotate_grid_vector(action.knockback, cause.facing)
		facing = -calc_facing(vector)
		position += calc_knockback(vector)
		reoriented.emit()
	
	if action.condition:
		add_condition(action.condition.duplicate())


func damage(num: int, type: Action.Type = Action.Type.NONE) -> void:
	var damage: int = -max(num - defense, 0)
	if type in type_weak: damage *= 2
	elif type in type_strong: damage /= 2
	add_will(damage)
	
	if is_defeated():
		defeated.emit()


func heal(num: int) -> void:
	add_will(num)


func try_evade(direction: Vector2i) -> bool:
	if false: # randf() <= evasion
		if Game.grid.is_tile_open(position + direction) and not is_incapacitated():
			facing = -direction
			position += direction
			evaded.emit()
			return true
		else:
			evade_failed.emit()
	
	return false



# modifiers

func add_trait(type: Trait.Type) -> void:
	Trait.apply(type, self)
	traits.append(type)


func remove_trait(type: Trait.Type) -> void:
	Trait.unapply(type, self)
	traits.erase(type)
	trait_removed.emit(type)


func initialize_traits() -> void:
	for type: Trait.Type in traits:
		Trait.apply(type, self)


func deinitialize_traits() -> void:
	for type: Trait.Type in traits:
		Trait.unapply(type, self)


func add_condition(condition: Condition) -> void:
	condition.actor = self
	condition.apply()
	conditions.append(condition)
	condition_added.emit(condition)


func remove_condition(condition: Condition) -> void:
	condition.unapply()
	conditions.erase(condition)
	condition_removed.emit(condition)


func has_condition(type: Condition.Type) -> bool:
	for condition: Condition in conditions:
		if condition.type == type:
			return true
	return false



# checks/calculations

func can_move() -> bool:
	return stamina > 0


func can_send_action(action: Action) -> bool:
	return action.cost <= stamina


func is_exhausted() -> bool:
	return stamina <= 0


func is_incapacitated() -> bool:
	return is_defeated() or has_condition(Condition.Type.SLEEP)


func is_defeated() -> bool:
	return will <= 0


func calc_facing(motion: Vector2i) -> Vector2i:
	var axis: int = motion.abs().max_axis_index()
	return (Vector2i.DOWN if axis else Vector2i.RIGHT) * signi(motion[axis])


func calc_knockback(vector: Vector2i) -> Vector2i:
	vector.x = max(abs(vector.x) - defense, 0) * sign(vector.x)
	vector.y = max(abs(vector.y) - defense, 0) * sign(vector.y)
	return Game.grid.collide_ray(position, vector)


func accuracy() -> float:
	return 0.5 * will / max_will + 0.5



# string

func _to_string() -> String:
	return name
