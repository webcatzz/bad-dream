class_name Battle
extends Node2D

@export var actors: Array[Actor]


func start() -> void:
	Game.battle = self
	
	Game.player.listening = false
	Game.player.stop_walking()
	
	get_tree().set_group("gate", "monitoring", false)
	
	actors.append(Game.player)
	for actor: Actor in actors:
		actor.position = Game.grid.snap(actor.position)
		actor.toggle_clickable(true)
		Game.grid.set_point_solid(actor.tile, true)
	
	cycle()


func cycle(idx: int = 0) -> void:
	for actor: Actor in actors:
		if idx % actor.turn_frequency == 0:
			await run_turn(actor)
		if actors.size() == 1:
			stop()
	
	cycle(idx + 1)


func stop() -> void:
	Game.battle = null
	
	Game.player.listening = true
	
	get_tree().set_group("gate", "monitoring", true)
	
	for actor: Actor in actors:
		actor.toggle_clickable(false)
	
	queue_free()



# turns

func run_turn(actor: Actor) -> void:
	Game.grid.set_point_solid(actor.tile, false)
	
	if actor.is_defeated():
		actors.erase(actor)
		return
	
	actor.replenish()
	await actor.take_turn()
	
	Game.grid.set_point_solid(actor.tile, true)


func remove_actor(actor: Actor) -> void:
	Game.grid.set_point_solid(actor.tile, false)
