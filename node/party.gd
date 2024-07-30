extends Node2D


func _ready() -> void:
	for i: int in range(Data.party.size() - 1, -1, -1):
		if not Data.party[i].node:
			Data.party[i].node = load("res://node/actor.tscn").instantiate()
			Data.party[i].node.data = Data.party[i]
		
		Data.party[i].node.position = position
		add_sibling.call_deferred(Data.party[i].node)
	
	queue_free()
