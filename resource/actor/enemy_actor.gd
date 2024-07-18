class_name EnemyActor extends Actor


@export var keep_distance: int
@export var preferred_facing: Vector2i = Vector2i(0, 1)

var paths: Dictionary
var target_priority: Array[Actor]
var damage_memory: Dictionary = {}

var turn_override: Array = []


func _take_turn() -> void:
	if turn_override:
		for override: Callable in turn_override: await override.call()
		turn_override.clear()
		end_turn()
		return
	
	update()
	var target: Actor = target_priority[0]
	var path: PackedVector2Array = paths[target]
	
	status()
	
	if path.size() < keep_distance:
		pass
	
	await follow_path(path)
	
	if path.size() <= tiles_per_turn:
		if actions:
			await perform_action(actions[0])
	
	end_turn()


## Follows [param path]. Pauses between points in [param path].
func follow_path(path: PackedVector2Array) -> void:
	if not path:
		await Game.get_tree().create_timer(0.2).timeout
		return
	
	for point: Vector2i in path:
		extend_path()
		move_to(point)
		node.advance_animation()
		await Game.get_tree().create_timer(0.2).timeout


func perform_action(action: Action) -> void:
	current_splash = Splash.new(action, self)
	Game.get_tree().current_scene.add_child(current_splash)
	await Game.get_tree().create_timer(0.25).timeout
	await take_action(action)


func update() -> void:
	paths = {}
	for actor: Actor in Data.get_party_undefeated():
		paths[actor] = get_path_to_actor(actor)
	
	target_priority = Data.get_party_undefeated()
	target_priority.sort_custom(func(a: Actor, b: Actor) -> bool:
		return (
			paths[a].size() < paths[b].size() or
			damage_memory.get(a, 0) > damage_memory.get(b, 0)
		)
	)
	prints(self, target_priority)



# priority

func recieve_action(action: Action, cause: Actor) -> void:
	super(action, cause)
	
	if action.type != Action.Type.HEALING:
		damage_memory[cause] = damage_memory.get(cause, 0) + action.strength



# path calculations

func get_path_to(point: Vector2i) -> PackedVector2Array:
	return Battle.field.get_point_path(position, point).slice(1)


func get_path_to_actor(actor: Actor) -> PackedVector2Array:
	var paths: Array[PackedVector2Array] = []
	
	for offset: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var target_point: Vector2i = actor.position + offset
		if position == target_point: return []
		if not Battle.field.is_point_travellable(target_point, node.get_rid()): continue
		
		var pre_target_point: Vector2i = target_point + Iso.rotate_grid_vector(offset, preferred_facing)
		if not Battle.field.is_point_travellable(pre_target_point, node.get_rid()): continue
		
		var path: PackedVector2Array = get_path_to(pre_target_point)
		if not path and position != pre_target_point: continue
		
		path.append(target_point)
		paths.append(path)
	
	sort_paths(paths)
	return paths[0] if paths else PackedVector2Array()


func sort_paths(paths: Array[PackedVector2Array]) -> void:
	paths.sort_custom(func(a: PackedVector2Array, b: PackedVector2Array) -> bool:
		return a.size() < b.size()
	)



# status

func status() -> void:
	if randf() > 0.25: return
	
	var messages: PackedStringArray
	
	if health == max_health:
		messages.append("%s seems awfully smug.")
	elif health < max_health * 0.25:
		messages.append("%s seems unsure.")
	elif health == 1:
		messages.append("%s looks glassy-eyed.")
	else:
		messages.append("%s is drooling.")
		messages.append("An awful smell is coming off %s.")
	
	if path.size() > 10:
		messages.append("%s takes off!")
	if status_effects:
		messages.append("%s is feeling a little queasy.")
	
	Battle.ui.run_status(messages[randi() % messages.size()] % name)
