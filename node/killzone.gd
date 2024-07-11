extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if Battle.active and body is ActorNode:
		body.data.die_badly()
