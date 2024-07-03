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
	
	var target: Actor = closest_targets[randi() % 1]
	
	await follow_path(paths[target].slice(0, owner.tiles_per_turn))
	
	if not paths[target] or owner.position == Vector2i(paths[target][-1]):
		if owner.actions:
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


## Follows [param path]. Pauses between points in [param path].
func follow_path(path: PackedVector2Array) -> void:
	if path:
		for point: Vector2i in path:
			owner.extend_path()
			owner.move_to(point)
			owner.node._advance_sprite_frame()
			await Game.get_tree().create_timer(0.2).timeout
	else:
		await Game.get_tree().create_timer(0.2).timeout
