class_name Battle
extends Node2D

@export var actors: Array[Actor]
@export var tilemap: TileMapLayer

var grid: Grid


func start() -> void:
	Game.battle = self
	
	Game.player.listening = false
	Game.player.stop_walking()
	
	get_tree().set_group("gate", "monitoring", false)
	
	grid = Grid.new(tilemap)
	
	actors.push_front(Game.player)
	for actor: Actor in actors:
		add_actor(actor, false)
	
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
	if actor.is_defeated():
		remove_actor(actor)
		return
	
	grid.set_point_solid(actor.tile, false)
	
	await actor.take_turn()
	actor.refresh()
	
	grid.set_point_solid(actor.tile, true)



# adding / removing

func add_actor(actor: Actor, list: bool = true) -> void:
	if list:
		actors.append(actor)
	
	actor.position = Grid.snap(actor.position)
	actor.set_clickable(true)
	actor.refresh()
	grid.set_point_solid(actor.tile, true)


func remove_actor(actor: Actor) -> void:
	actors.erase(actor)
	
	actor.set_clickable(false)
	grid.set_point_solid(actor.tile, false)
