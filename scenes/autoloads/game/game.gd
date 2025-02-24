extends Node3D

const PICK_DISTANCE: float = 100

var file := ConfigFile.new()

var player: Player
var battle: Battle

var world: World3D

@onready var cursor: Sprite2D = $Overlay/Cursor


func change_scene(filename: String, target_gate: String = "") -> void:
	get_tree().change_scene_to_file("res://scenes/places/%s.tscn" % filename)
	await get_tree().tree_changed
	
	for gate: Node2D in get_tree().get_nodes_in_group("gate"):
		if gate.name == target_gate:
			gate.receive()
			break



# physics

func pick(screen_position: Vector2) -> Dictionary:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var params := PhysicsRayQueryParameters3D.new()
	params.from = camera.project_ray_origin(screen_position)
	params.to = params.from + camera.project_ray_normal(screen_position) * PICK_DISTANCE
	return get_world_3d().direct_space_state.intersect_ray(params)


func at(point: Vector3) -> Array[CollisionObject3D]:
	var params := PhysicsPointQueryParameters3D.new()
	params.position = point
	return get_world_3d().direct_space_state.intersect_point(params).map(_collision_to_collider)


func _collision_to_collider(collision: Dictionary) -> CollisionObject3D:
	return collision.collider



# save & load

func load_file() -> void:
	file.load("user://save.cfg")


func save_file() -> void:
	file.save("user://save.cfg")



# init

func _ready() -> void:
	load_file()
