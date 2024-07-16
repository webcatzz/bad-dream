class_name EnemyActor extends Actor


@export var keep_distance: int
@export var preferred_facing: Vector2i = Vector2i(0, 1)

var paths: Dictionary
var closest_targets: Array[Actor]

var turn_override: Array = []


func _take_turn() -> void:
	if turn_override:
		for override: Callable in turn_override: await override.call()
		turn_override.clear()
		if is_exhausted():
			end_turn()
			return
	
	update()
	
	var target: Actor = closest_targets[0]
	var path: PackedVector2Array = paths[target]
	
	if path.size() < keep_distance:
		pass
	
	if await follow_path(path):
		if actions:
			await perform_action(actions[0])
	
	end_turn()


## Follows [param path]. Pauses between points in [param path].
func follow_path(path: PackedVector2Array) -> bool:
	if not path:
		await Game.get_tree().create_timer(0.2).timeout
		return true
	
	for point: Vector2i in path:
		if not can_move(): return false
		
		extend_path()
		move_to(point)
		node._advance_sprite_frame()
		await Game.get_tree().create_timer(0.2).timeout
	
	return true


func perform_action(action: Action) -> void:
	current_splash = Splash.new(action, self)
	Game.get_tree().current_scene.add_child(current_splash)
	await Game.get_tree().create_timer(0.25).timeout
	await take_action(action)


func update() -> void:
	paths = {}
	for actor: Actor in Data.get_party_undefeated():
		paths[actor] = get_path_to_actor(actor)
	
	closest_targets = Data.get_party_undefeated()
	closest_targets.sort_custom(func(a: Actor, b: Actor) -> bool:
		return paths[a].size() < paths[b].size()
	)



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
	return paths[0] if paths else []


func sort_paths(paths: Array[PackedVector2Array]) -> void:
	paths.sort_custom(func(a: PackedVector2Array, b: PackedVector2Array) -> bool:
		return a.size() < b.size()
	)
