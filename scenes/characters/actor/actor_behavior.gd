class_name ActorBehavior

var puppet: Actor


func act(puppet: Actor) -> void:
	pass


func on_adjacency_changed(puppet: Actor, actor: Actor, adjacent: bool) -> void:
	if puppet.can_react and not adjacent and puppet.can_strike(actor):
		puppet.strike(actor)



# virtual

func _init(actor: Actor) -> void:
	puppet = actor
