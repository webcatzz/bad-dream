class_name Consumable extends Item


@export var action: Action


func use(cause: Actor) -> void:
	await action.start(cause)
