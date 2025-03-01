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


func cycle(idx: int = 0) -> void:
	var i: int = 0
	while i < actors.size():
		
		if idx % actors[i].turn_frequency == 0:
			await run_turn(actors[i])
			await get_tree().create_timer(0.5).timeout
		
		if Game.player not in actors or actors.size() < 2:
			stop()
			return
		
		i += 1
	cycle(idx + 1)


func stop() -> void:
	Game.battle = null
	Game.player.listening = true
	
	get_tree().set_group("gate", "monitoring", true)
	
	while actors:
		remove_actor(actors.back())
	
	queue_free()



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
	actor.set_clickable(true)
	grid.set_coords_open(actor.coords, false)


func remove_actor(actor: Actor) -> void:
	actors.erase(actor)
	actor.set_clickable(false)
	grid.set_coords_open(actor.coords, true)
