class_name DamageZone extends StaticBody2D


@export var damage: int


func _ready() -> void:
	Battle.started.connect($Collision.set_disabled.bind(true), CONNECT_DEFERRED)
	Battle.ended.connect($Collision.set_disabled.bind(false), CONNECT_DEFERRED)


func _on_body_entered(body: Node2D) -> void:
	if Battle.active and body is ActorNode:
		if damage == -1: body.data.die_badly()
		else: body.data.damage(damage)
