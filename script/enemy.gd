class_name Enemy extends Actor


var damage_memory: Dictionary = {} # fix [Actor, int]
var target_priority: Array[Actor]
var paths: Dictionary


func act() -> void:
	pass



# priority

func get_target() -> Actor:
	return rank_targets()[randi_range(0, 1)]


func rank_targets() -> Array[Actor]:
	var ranking: Dictionary # fix [Actor, int]
	for actor: Actor in Save.party:
		ranking[actor] = damage_memory[actor]/2.0 - get_paths_to_actor(actor)[0].size()
	
	var list: Array[Actor] = Save.party.duplicate()
	list.sort_custom(func(a: Actor, b: Actor) -> bool: return ranking[a] > ranking[b])
	return list


func recieve_action(action: Action, cause: Actor) -> void:
	super(action, cause)
	
	if action.type != Action.Type.HEALING:
		damage_memory[cause] = damage_memory.get(cause, 0) + action.strength



# pathing

func follow_path(path: PackedVector2Array) -> void:
	#if not path:
		#await Game.get_tree().create_timer(0.2).timeout
		#return
	
	for point: Vector2i in path:
		add_to_path()
		move_to(point)
		await Game.get_tree().create_timer(0.2).timeout


func get_path_to(point: Vector2i) -> PackedVector2Array:
	return Game.battle.field.get_point_path(position, point).slice(1)


func get_paths_to_actor(actor: Actor) -> Array[PackedVector2Array]:
	var paths: Array[PackedVector2Array] = []
	
	for offset: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var target_point: Vector2i = actor.position + offset
		if position == target_point: return [[]]
		if not Game.battle.field.is_point_travellable(target_point, node.get_rid()): continue
		
		var pre_target_point: Vector2i = target_point + offset
		if not Game.battle.field.is_point_travellable(pre_target_point, node.get_rid()): continue
		
		var path: PackedVector2Array = get_path_to(pre_target_point)
		if not path and position != pre_target_point: continue
		
		path.append(target_point)
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
