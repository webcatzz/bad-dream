class_name Battle
extends Node2D

enum State {
	IDLE,
	INPUT_TURN,
	AUTO_TURN,
}

@export var actors: Array[Actor]

var state: State

@onready var selector: CharacterBody2D = $Selector


func start() -> void:
	Game.battle = self
	Game.player.listening = false
	
	actors.append(Game.player)
	for actor in actors:
		actor.stop_walking()
		actor.position = Game.grid.snap(actor.position)
		Game.grid.set_point_solid(actor.tile, true)
	
	selector.camera.enabled = true
	selector.camera.make_current()
	
	cycle()


func cycle(idx: int = 0) -> void:
	for actor: Actor in actors:
		if idx % actor.turn_frequency == 0:
			await run_turn(actor)
		if actors.size() == 1:
			stop()
	
	cycle(idx + 1)


func stop() -> void:
	Game.player.listening = true
	queue_free()



# turns

func run_turn(actor: Actor) -> void:
	Game.grid.set_point_solid(actor.tile, false)
	
	if actor.is_defeated():
		actors.erase(actor)
		return
	else:
		actor.replenish()
	
	if actor.friendly:
		await input_turn(actor)
	else:
		await auto_turn(actor)
	
	Game.grid.set_point_solid(actor.tile, true)


func remove_actor(actor: Actor) -> void:
	Game.grid.set_point_solid(actor.tile, false)



# input turn

func input_turn(actor: Actor) -> void:
	state = State.INPUT_TURN
	selector.mode = selector.Mode.SKIMMING
	selector.position = Game.player.position
	
	await actor.exhausted
	
	selector.mode = selector.Mode.DISABLED



# auto turn

func auto_turn(actor: Actor) -> void:
	state = State.AUTO_TURN
	await get_tree().create_timer(1).timeout
