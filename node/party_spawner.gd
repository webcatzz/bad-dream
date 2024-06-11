class_name PartySpawner extends Node2D
## Spawns party actors' nodes.


func _ready() -> void:
	for actor: Actor in Game.data.party:
		if actor.node:
			get_parent().add_child.call_deferred(actor.node)
		else:
			var node: PartyActorNode = load("res://node/player_actor.tscn" if actor == Game.data.get_leader() else "res://node/party_actor.tscn").instantiate()
			node.data = actor
			get_parent().add_child.call_deferred(node)
