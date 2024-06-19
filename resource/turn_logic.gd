class_name TurnLogic


enum Type {
	MELEE, ## Move up to a target and attack.
}


@export var type: Type
@export var keep_distance: int
@export var in_party: bool


func start() -> void:
	var target: Actor = Game.data.get_leader()
	Battle.astar.region.position
