extends Node

signal started
signal actor_added(actor: Actor, idx: int)
signal actor_removed(idx: int)
signal turn_started(actor: Actor)
signal turn_ended(actor: Actor)
signal ended

var active: bool
var current: Actor
var order: Array[Actor]


func start(actors: Array[Actor]) -> void:
	active = true
	randomize()
	for actor in Data.party + actors: add_actor(actor) # constructing order
	started.emit()
	run_order()


func run_order() -> void:
	for actor in order:
		current = actor
		await actor.take_turn()
	run_order()


func add_actor(actor: Actor) -> void:
	actor.order = randi_range(0, 75) + actor.speed
	var idx: int
	# in case of lowest order, jumps to end:
	if order.is_empty() or actor.order < order[-1].order: idx = order.size()
	# otherwise, inserts before first actor with lower order:
	else: for i in order.size():
		if actor.order < order[i].order: continue
		idx = i
		if actor.order == order[i].order and (actor.speed < order[i].speed or actor.speed == order[i].speed and randf() > 0.5):
			idx += 1
		break
	# signals
	actor.defeated.connect(remove_actor.bind(actor))
	actor.turn_started.connect(emit_signal.bind("turn_started", actor))
	actor.turn_ended.connect(emit_signal.bind("turn_ended", actor))
	# adding
	order.insert(idx, actor)
	actor_added.emit(actor, idx)


func remove_actor(actor: Actor) -> void:
	var idx: int = order.find(actor)
	# signals
	actor.defeated.disconnect(remove_actor)
	actor.turn_started.disconnect(emit_signal)
	actor.turn_ended.disconnect(emit_signal)
	# removing
	order.erase(actor)
	actor_removed.emit(idx)


func stop() -> void:
	active = false
	order = []
	ended.emit()
