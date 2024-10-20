class_name Enemy extends Actor


var damage_memory: Dictionary = {} # fix [Actor, int]
var target_priority: Array[Actor]
var paths: Dictionary


func act() -> void:
	await follow_path(get_path_to_actor(pick_target()))
	
	if can_send_action(actions[0]):
		Game.battle.preview_action(actions[0], self)
		await Game.get_tree().create_timer(0.5).timeout
		Game.battle.clear_highlight()
		
		send_action(actions[0])
		await Game.get_tree().create_timer(1).timeout



# priority

func pick_target() -> Actor:
	return rank_targets()[0]


func rank_targets() -> Array[Actor]:
	var ranking: Dictionary # fix [Actor, int]
	for actor: Actor in Save.party:
		ranking[actor] = damage_memory.get(actor, 0) - get_path_to_actor(actor).size()
	
	var list: Array[Actor] = Save.party.duplicate()
	list.sort_custom(func(a: Actor, b: Actor) -> bool: return ranking[a] > ranking[b])
	return list


func recieve_action(action: Action, cause: Actor) -> void:
	super(action, cause)
	
	if action.type != Action.Type.HEALING:
		if is_defeated():
			defeated.emit()
		else:
			damage_memory[cause] = damage_memory.get(cause, 0) + action.strength



# pathing

func follow_path(path: PackedVector2Array) -> void:
	for point: Vector2i in path:
		add_to_path()
		move_to(point)
		await Game.get_tree().create_timer(0.2).timeout
		if not stamina: return


func get_path_to_actor(actor: Actor) -> PackedVector2Array:
	return get_paths_to_actor(actor)[0]


func get_paths_to_actor(actor: Actor) -> Array[PackedVector2Array]:
	var paths: Array[PackedVector2Array] = []
	
	for offset: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var target_tile: Vector2i = actor.position + offset
		if target_tile == position: return [[]]
		
		var params: PhysicsPointQueryParameters2D = Game.battle.field.point_params(target_tile)
		params.exclude.append(node.get_rid())
		if not Game.battle.field.is_tile_open(params): continue
		
		var pre_target_tile: Vector2i = target_tile + offset
		params.position = Iso.from_grid(pre_target_tile)
		if not Game.battle.field.is_tile_open(params): continue
		
		var path: PackedVector2Array = Game.battle.field.get_tile_path(position, pre_target_tile)
		if not path and position != pre_target_tile: continue
		path.append(target_tile)
		paths.append(path)
	
	sort_paths(paths)
	return paths


func sort_paths(paths: Array[PackedVector2Array]) -> void:
	paths.sort_custom(func(a: PackedVector2Array, b: PackedVector2Array) -> bool:
		return a.size() < b.size()
	)



# updating

func update() -> void:
	pass
