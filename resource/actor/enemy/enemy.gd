class_name Enemy extends Actor


var targets: Array[Actor]
var damage_memory: Dictionary = {} # fix [Actor, int]
var paths: Dictionary


func act() -> void:
	await Game.get_tree().create_timer(0.5).timeout
	
	await follow_path(paths[get_target()])
	
	if can_send_action(actions[0]):
		Game.battle.preview_action(actions[0], self)
		await Game.get_tree().create_timer(0.5).timeout
		Game.battle.clear_highlight()
		
		send_action(actions[0])
		await Game.get_tree().create_timer(1).timeout



# updating

func get_target() -> Actor:
	var ranking: Dictionary # fix [Actor, int]
	var target: Actor = Save.leader
	
	for actor: Actor in Save.party:
		paths[actor] = get_path_to_actor(actor)
		ranking[actor] = damage_memory.get(actor, 0) - paths[actor].size()
		
		if ranking[actor] > ranking[target]:
			target = actor
	
	return target



# targeting

func recieve_action(action: Action, cause: Actor) -> void:
	super(action, cause)
	
	if action.type != Action.Type.HEALING:
		damage_memory[cause] = damage_memory.get(cause, 0) + action.strength



# pathing

#func follow_path(path: PackedVector2Array) -> void:
	#for point: Vector2i in path:
		#add_to_path()
		#move_to(point)
		#Game.battle.selector.position = Iso.from_grid(position)
		#await Game.get_tree().create_timer(0.2).timeout
		#if not stamina: return


func get_path_to_actor(actor: Actor) -> PackedVector2Array:
	var shortest_path: PackedVector2Array
	
	for offset: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var target_tile: Vector2i = actor.position + offset
		
		if Game.grid.is_tile_open(target_tile):
			var pre_target_tile: Vector2i = target_tile + offset
			
			var path: PackedVector2Array = Game.grid.get_id_path(position, pre_target_tile).slice(1)
			if path or position == pre_target_tile:
				path.append(target_tile)
				
				if not shortest_path or (
					path.size() < shortest_path.size() and
					(not path.size() == 0 or position == pre_target_tile) 
				):
					shortest_path = path
	
	return shortest_path
