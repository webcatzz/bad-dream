extends Node
## Battle manager.


signal started
signal ended
signal turn_started(actor: Actor)
signal turn_ended(actor: Actor)
signal actor_added(actor: Actor, idx: int)
signal actor_removed(idx: int)

const FieldAStar = preload("res://script/battle_astar.gd") ## Pathfinding algorithm.

var active: bool ## Whether there is a battle currently active.
var order: Array[Actor] ## The order in which [Actor]s take turns.
var current_idx: int ## The current index in [member order].
var current_actor: Actor ## The [Actor] currently taking their turn.

var field: FieldAStar
var astar_draw: Node2D # DEBUG

var ui: Node



# battle starting + stopping

## Starts a battle between the party and [param actors].
func start(actors: Array[Actor], region: Rect2i) -> void:
	active = true
	
	# adding ui/camera
	ui = preload("res://node/ui/battle.tscn").instantiate()
	add_child(ui)
	
	# generating field grid
	field = FieldAStar.new(region)
	
	# adding actors
	for actor: Actor in Data.party: add_actor(actor)
	for actor: Actor in actors: add_actor(actor)
	
	# starting order
	started.emit()
	current_idx = order.find(Data.get_leader()) - 1
	run_turn()


## Loops through [member order] until [method is_won] returns true.
func run_turn() -> void:
	current_idx = (current_idx + 1) % order.size()
	current_actor = order[current_idx] # fetching current actor
	
	if not current_actor.is_defeated():
		turn_started.emit(current_actor)
		await current_actor.take_turn()
		turn_ended.emit(current_actor)
	
	current_actor = null
	await get_tree().create_timer(0.25).timeout
	
	# moving to next turn
	if not Data.get_party_undefeated():
		stop()
		Game.over()
	else:
		for actor: Actor in order:
			if actor not in Data.party and not actor.is_defeated():
				run_turn()
				return
		stop()


## Ends the current battle.
func stop() -> void:
	active = false
	field = null
	
	# ending battle
	ended.emit()
	
	# removing actors
	while order: remove_actor(order[-1])
	
	# reorder party & regenerate nodes if leader is defeated
	if Data.get_leader().is_defeated() and Data.get_party_undefeated():
		
		# freeing old leader node
		var position: Vector2 = Data.get_leader().node.position
		Data.get_leader().node.queue_free()
		Data.get_leader().node = null
		
		# choosing new leader & freeing its node
		var new_leader: Actor = Data.get_party_undefeated()[0]
		new_leader.node.queue_free()
		new_leader.node = null
		Data.party.erase(new_leader)
		Data.party.push_front(new_leader)
		
		# spawning party
		Game.spawn_party(position)



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
	if idx <= current_idx: current_idx += 1
	actor.in_battle = true
	actor_added.emit(actor, idx)


## Removes an actor from the current battle's [member order].
func remove_actor(actor: Actor) -> void:
	var idx: int = order.find(actor)
	
	# removing from order
	order.remove_at(idx)
	actor.in_battle = false
	actor_removed.emit(idx)
