extends EnemyAI


func act() -> void:
	if puppet.can_stand(puppet.position + Grid.DOWN):
		puppet.move(puppet.position + Grid.DOWN)
	else:
		var target: CollisionObject2D = Game.battle.grid.at(puppet.position + Grid.DOWN)
		if puppet.can_attack(target):
			puppet.attack(target)
	
	puppet.animator.play("exhausted")
