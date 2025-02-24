extends ActorBehavior

var direction: Vector3 = Vector3.FORWARD


func act() -> void:
	if not await try_move(puppet.position + direction):
		if not await try_attack(Game.battle.grid.at(puppet.position + direction)):
			direction = -direction
			await try_move(puppet.position + direction)
	
	puppet.animator.queue("exhausted")
