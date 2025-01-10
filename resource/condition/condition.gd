class_name Condition
extends Resource

var target: Actor


func apply(actor: Actor) -> void:
	target = actor


func unapply(actor: Actor) -> void:
	target = null


func tick() -> void:
	pass
