extends Node
## Battle manager.


signal started
signal ended
signal turn_started(actor: Actor)
signal turn_ended(actor: Actor)
signal actor_added(actor: Actor, idx: int)
signal actor_removed(idx: int)

var active: bool ## Whether there is a battle currently active.
var order: Array[Actor] ## The order in which [Actor]s take turns.
var current_idx: int ## The current index in [member order].
var current_actor: Actor ## The [Actor] currently taking their turn.

var region: Rect2i ## Travellable space.
var astar: AStarGrid2D ## Pathfinding algorithm.
var astar_draw: Node2D



# battle starting + stopping

## Starts a battle between the party and [param actors].
func start(actors: Array[Actor], region: Rect2i) -> void:
	active = true
	self.region = region
	_generate_astar(region) # generating field grid
	
	# adding actors
	for actor: Actor in Game.data.party: add_actor(actor)
	for actor: Actor in actors: add_actor(actor)
	
	# starting order
	started.emit()
	current_idx = -1
	run_turn()


## Returns true if there are no non-party [Actor]s in [member order].
func is_won() -> bool:
	for actor in order:
		if actor not in Game.data.party and not actor.is_incapacitated():
			return false
	return true


## Ends the current battle.
func stop() -> void:
	active = false
	astar = null
	
	# ending battle
	ended.emit()
	
	# removing actors
	while order: remove_actor(order[-1])



# turns

## Loops through [member order] until [method is_won] returns true.
func run_turn() -> void:
	current_idx = (current_idx + 1) % order.size()
	current_actor = order[current_idx] # fetching current actor
	
	if current_actor.health > 0:
		turn_started.emit(current_actor)
		await current_actor.take_turn()
		turn_ended.emit(current_actor)
	
	current_actor = null
	await get_tree().create_timer(0.25).timeout
	
	# moving to next turn
	if is_won(): stop()
	else: run_turn()



# actors

## Adds an actor to the current battle's [member order].
func add_actor(actor: Actor) -> void:
	var idx: int
	
	if order.is_empty() or order[-1].tiles_per_turn >= actor.tiles_per_turn:
		idx = order.size() # in case of lowest speed
	else:
		for i in order.size():
			if actor.tiles_per_turn > order[i].tiles_per_turn:
				idx = i
				break
	
	# adding to order
	order.insert(idx, actor)
	actor.in_battle = true
	actor.defeated.connect(remove_actor.bind(actor))
	actor_added.emit(actor, idx)


## Removes an actor from the current battle's [member order].
func remove_actor(actor: Actor) -> void:
	var idx: int = order.find(actor)
	
	# removing from order
	order.remove_at(idx)
	actor.in_battle = false
	actor.defeated.disconnect(remove_actor)
	actor_removed.emit(idx)



# internal

func _ready() -> void:
	add_child(load("res://node/ui/battle.tscn").instantiate()) # ui
	add_child(load("res://node/battle_camera.gd").new()) # camera
	
	astar_draw = load("res://node/astar_draw.gd").new()
	add_child(astar_draw) # astar draw


# Updates [member astar] grid to current battle region.
func _generate_astar(region: Rect2i) -> void:
	astar = AStarGrid2D.new()
	astar.region = region
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	
	
	# grid from physics
	var space_state: PhysicsDirectSpaceState2D = Game.get_root().get_world_2d().direct_space_state
	var point_query := PhysicsPointQueryParameters2D.new()
	
	for x in region.size.x: for y in region.size.y:
		var point: Vector2i = Vector2i(x, y) + region.position
		point_query.position = Iso.from_grid(point)
		
		var intersections: Array[Dictionary] = space_state.intersect_point(point_query)
		if intersections:
			for intersection: Dictionary in intersections:
				if not intersection.collider is ActorNode:
					astar.set_point_solid(point, true)
					break
