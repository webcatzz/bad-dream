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
	
	var target: Actor = closest_targets[0]
	
	await follow_path(paths[target].slice(0, owner.tiles_per_turn))
	
	if not paths[target] or owner.position == Vector2i(paths[target][-1]):
		Game.get_tree().current_scene.add_child(owner.actions[0].splash)
		await Game.get_tree().create_timer(0.25).timeout
		await owner.take_action(owner.actions[0])
	
	owner.end_turn()
	
	# TODO: move back if too close for keep_distance


func update() -> void:
	paths = {}
	for actor: Actor in Data.party:
		if not actor.is_defeated():
			var path: PackedVector2Array = Battle.astar.get_point_path(owner.position, actor.position)
			paths[actor] = Battle.astar.get_point_path(owner.position, actor.position).slice(1, -1)
	
	closest_targets = Data.get_party_undefeated()
	closest_targets.sort_custom(func(a: Actor, b: Actor) -> bool:
		return paths[a].size() < paths[b].size()
	)


func follow_path(path: PackedVector2Array) -> void:
	for point: Vector2i in path:
		owner.move(point)
		await Game.get_tree().create_timer(0.2).timeout
