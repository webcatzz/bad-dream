class_name BurnCondition
extends Condition


func apply(actor: Actor) -> void:
	super(actor)
	actor.attacked.connect(tick)


func unapply(actor: Actor) -> void:
	actor.attacked.disconnect(tick)
	super(actor)
