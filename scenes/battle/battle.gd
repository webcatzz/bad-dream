class_name Battle
extends Node

@export var grid: Grid
@export var actors: Array[Actor]


func start() -> void:
	Game.battle = self
	Game.player.listening = false
	Game.player.stop_walking()
	
	actors.push_front(Game.player)
	for actor: Actor in actors:
		ready_actor(actor)
	
	cycle()


func cycle() -> void:
	var idx: int = 0
	while idx < actors.size():
		await run_turn(actors[idx])
		await get_tree().create_timer(0.5).timeout
		
		if is_over():
			stop()
			return
		
		idx += 1
	
	cycle()


func stop() -> void:
	Game.battle = null
	Game.player.listening = true
	
	while actors:
		remove_actor(actors.back())
	
	queue_free()


func is_over() -> bool:
	return Game.player not in actors or actors.size() < 2



# turns

func run_turn(actor: Actor) -> void:
	if actor.is_defeated:
		remove_actor(actor)
		return
	
	grid.set_coords_open(actor.coords, true)
	await actor.take_turn()
	grid.set_coords_open(actor.coords, false)



# adding & removing

func ready_actor(actor: Actor) -> void:
	actor.position = Grid.snap(actor.position)
	grid.set_coords_open(actor.coords, false)


func remove_actor(actor: Actor) -> void:
	actors.erase(actor)
	grid.set_coords_open(actor.coords, true)
