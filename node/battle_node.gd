extends Node


@export var enemy_paths: Array[NodePath]


func start() -> void:
	var enemies: Array[Enemy]
	
	for path: NodePath in enemy_paths:
		enemies.append(get_node(path).resource)
	
	Game.start_battle(enemies)



# debug

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	start()
