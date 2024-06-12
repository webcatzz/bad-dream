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

var astar: AStarGrid2D = AStarGrid2D.new() ## Pathfinding algorithm.

# nodes
var _modulator: CanvasModulate = CanvasModulate.new()



# setup

func _ready() -> void:
	# modulator (darkens scene when active)
	_modulator.color = Color.WHITE
	_modulator.visible = false
	add_child(_modulator)
	
	# ui
	add_child(load("res://node/ui/battle.tscn").instantiate())



# battle starting + stopping

## Starts a battle between the party and [param actors].
func start(actors: Array[Actor]) -> void:
	active = true
	
	# adding actors
	for actor: Actor in Game.data.party: add_actor(actor)
	for actor: Actor in actors: add_actor(actor)
	
	# starting order
	started.emit()
	run_turn()
	
	# sound/visual
	_modulator.visible = true
	get_tree().create_tween().tween_property(_modulator, "color:v", 0.8, 2)


## Returns true if there are no non-party [Actor]s in [member order].
func is_won() -> bool:
	for actor in order:
		if actor not in Game.data.party:
			return false
	return true


## Ends the current battle.
func stop() -> void:
	active = false
	
	# ending battle
	ended.emit()
	
	# removing actors
	for actor in order: remove_actor(actor)
	
	# sound/visual
	await get_tree().create_tween().tween_property(_modulator, "color:v", 1, 2).finished
	_modulator.visible = false



# turns

## Loops through [member order] until [method is_won] returns true.
func run_turn() -> void:
	current_idx = (current_idx + 1) % order.size()
	current_actor = order[current_idx]
	
	if current_actor.health > 0:
		turn_started.emit()
		await current_actor.take_turn()
		turn_ended.emit()
	
	await get_tree().create_timer(0.25).timeout
	if is_won(): stop()
	else: run_turn()



# actors

## Adds an actor to the current battle's [member order].
func add_actor(actor: Actor) -> void:
	var idx: int
	
	# if this actor has the lowest speed, it is inserted at the end of the order
	if order.is_empty() or actor.tiles_per_turn < order[-1].tiles_per_turn:
		idx = order.size()
	# otherwise: inserts before the first actor with lower speed
	else:
		for i in order.size():
			if actor.tiles_per_turn > order[i].tiles_per_turn:
				idx = i
				break
	
	# adding to order
	order.insert(idx, actor)
	actor.in_battle = true
	actor_added.emit(actor, idx)
	
	actor.defeated.connect(remove_actor.bind(actor))


## Removes an actor from the current battle's [member order].
func remove_actor(actor: Actor) -> void:
	var idx: int = order.find(actor)
	
	# removing from order
	actor.in_battle = false
	order.erase(actor)
	actor_removed.emit(idx)
