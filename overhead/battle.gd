extends Node

signal started
signal actor_added(actor: Resource, idx: int)
signal actor_removed(idx: int)
signal ended

var active: bool
var current: Resource
var order: Array[Resource]


func start(actors: Array[Resource]):
	active = true
	randomize()
	for actor in Data.party + actors: add_actor(actor) # constructing order
	started.emit()
	run_order()


func run_order():
	for actor in order:
		current = actor
		await actor.take_turn()
	run_order()


func add_actor(actor: Resource):
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
	
	actor.defeated.connect(remove_actor.bind(actor))
	order.insert(idx, actor)
	actor_added.emit(actor, idx)


func remove_actor(actor: Resource):
	var idx: int = order.find(actor)
	order.erase(actor)
	actor_removed.emit(actor, idx)


func stop():
	active = false
	order = []
	ended.emit()
