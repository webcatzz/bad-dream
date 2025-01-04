class_name EnemyAI

var puppet: Actor


func act() -> void:
	pass


func try_move(point: Vector2) -> bool:
	if puppet.can_stand(point):
		await puppet.move(point)
		return true
	return false


func try_attack(target: CollisionObject2D) -> bool:
	if puppet.can_attack(target):
		await puppet.attack(target)
		return true
	return false


func on_actor_adjacency_changed(actor: Actor, adjacent: bool) -> void:
	if puppet.can_react and not adjacent and puppet.can_attack(actor):
		puppet.attack(actor)



# init

func _init(actor: Actor) -> void:
	puppet = actor
