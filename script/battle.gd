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

var astar: FieldAStar
var astar_draw: Node2D # DEBUG



# battle starting + stopping

## Starts a battle between the party and [param actors].
func start(actors: Array[Actor], region: Rect2i) -> void:
	active = true
	
	# generating field grid
	astar = FieldAStar.new(region)
	
	# adding actors
	for actor: Actor in Game.data.party: add_actor(actor)
	for actor: Actor in actors: add_actor(actor)
	
	# starting order
	started.emit()
	current_idx = -1
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
	if is_won(): stop()
	else: run_turn()


## Returns true if there are no undefeated enemy [Actor]s in [member order].
func is_won() -> bool:
	for actor in order:
		if actor not in Game.data.party and not actor.is_defeated():
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
	actor_added.emit(actor, idx)


## Removes an actor from the current battle's [member order].
func remove_actor(actor: Actor) -> void:
	var idx: int = order.find(actor)
	
	# removing from order
	order.remove_at(idx)
	actor.in_battle = false
	actor_removed.emit(idx)



# internal

func _ready() -> void:
	add_child(load("res://node/ui/battle.tscn").instantiate()) # ui
	add_child(load("res://node/battle_camera.gd").new()) # camera
	
	astar_draw = load("res://node/astar_draw.gd").new()
	add_child(astar_draw) # astar draw
