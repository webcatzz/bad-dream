class_name PartySpawner extends Node2D
## Spawns party actors' nodes.


func _ready() -> void:
	for actor: Actor in Game.data.party:
		if not actor.node:
			actor.node = load("res://node/actor/player_actor.tscn" if actor == Game.data.get_leader() else "res://node/actor/party_actor.tscn").instantiate()
			actor.node.data = actor
		
		actor.node.tree_entered.connect(actor.node.set_position.bind(position), CONNECT_ONE_SHOT)
		if actor.is_defeated(): actor.node.tree_entered.connect(actor.node._on_defeated, CONNECT_ONE_SHOT)
		get_parent().add_child.call_deferred(actor.node)
	
	queue_free()
