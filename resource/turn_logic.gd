class_name TurnLogic extends Resource


enum Type {
	MELEE, ## Move up to a target and attack.
}

@export var type: Type
@export var keep_distance: int
@export var in_party: bool

@export var owner: Actor

var paths: Dictionary
var closest_targets: Array[Actor]


func start() -> void:
	update()
	
	await follow_path(paths[closest_targets[0]].slice(0, owner.tiles_per_turn))
	
	owner.end_turn()
	
	# TODO: move back if too close for keep_distance


func update() -> void:
	paths = {}
	for actor: Actor in Game.data.party:
		if not actor.is_defeated():
			var path: PackedVector2Array = Battle.astar.get_point_path(owner.position, actor.position)
			path.remove_at(0)
			path.resize(path.size() - 1)
			paths[actor] = path
	
	closest_targets = Game.data.party.duplicate()
	closest_targets.sort_custom(func(a: Actor, b: Actor) -> bool:
		return paths[a].size() < paths[b].size()
	)


func follow_path(path: PackedVector2Array) -> void:
	for point: Vector2i in path:
		owner.move(point)
		await Game.get_tree().create_timer(0.2).timeout
