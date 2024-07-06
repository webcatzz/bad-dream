class_name Consumable extends Item


@export var effect: Action = Action.new()


func use(by: Actor) -> void:
	var action: Action = effect.duplicate()
	action.cause = by
	await action.start()
