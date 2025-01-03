class_name EnemyAI

var puppet: Actor


func act() -> void:
	pass


func on_actor_adjacency_changed(actor: Actor, adjacent: bool) -> void:
	if puppet.can_react and not adjacent and puppet.can_attack(actor):
		print(1)
		puppet.attack(actor)



# init

func _init(actor: Actor) -> void:
	puppet = actor
