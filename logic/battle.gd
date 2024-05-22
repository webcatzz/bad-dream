extends Node
## Battle manager.


signal started
signal ended
signal actor_added(actor: Actor, idx: int)
signal actor_removed(idx: int)
signal turn_started(actor: Actor)
signal turn_ended(actor: Actor)


## Whether there is a battle currently active.
var active: bool
## The [Actor] currently taking their turn.
var current_actor: Actor
## [Actor]s take turns according to this order.
var order: Array[Actor]



# battle starting + stopping

## Starts a battle between the party and [member actors].
func start(actors: Array[Actor]) -> void:
	active = true
	randomize()
	for actor in Game.data.party + actors: add_actor(actor) # constructing order
	started.emit()
	run_order()
	
	prints("Started battle with order:", order)

## Loops through [member order] until [method is_won] returns true.
func run_order() -> void:
	for actor in order:
		current_actor = actor
		await actor.take_turn()
		
		if is_won():
			stop()
			return
	
	run_order()

## Returns true if there are no non-party [Actor]s in [member order].
func is_won() -> bool:
	for actor in order:
		if actor not in Game.data.party:
			return false
	return true

## Ends the current battle.
func stop() -> void:
	active = false
	for actor in order: remove_actor(actor)
	ended.emit()



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
	
	# connecting signals
	actor.defeated.connect(remove_actor.bind(actor))
	actor.turn_started.connect(emit_signal.bind("turn_started", actor))
	actor.turn_ended.connect(emit_signal.bind("turn_ended", actor))
	
	# adding to order
	order.insert(idx, actor)
	actor_added.emit(actor, idx)

## Removes an actor from the current battle's [member order].
func remove_actor(actor: Actor) -> void:
	var idx: int = order.find(actor)
	
	# disconnecting signals
	actor.defeated.disconnect(remove_actor)
	actor.turn_started.disconnect(emit_signal)
	actor.turn_ended.disconnect(emit_signal)
	
	# removing from order
	order.erase(actor)
	actor_removed.emit(idx)
