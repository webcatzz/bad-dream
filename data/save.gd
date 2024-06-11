extends Resource


# party
@export var party: Array[Actor] = [load("res://data/actor/woodcarver.tres"), Actor.new(), Actor.new()]

# world
@export var scene_path: String
@export var position: Vector2

# volume
@export var master_volume: float = 1:
	set(value):
		master_volume = value
		AudioServer.set_bus_volume_db(0, linear_to_db(value))
@export var music_volume: float = 0:
	set(value):
		music_volume = value
		AudioServer.set_bus_volume_db(1, linear_to_db(value))
@export var sfx_volume: float = 1:
	set(value):
		sfx_volume = value
		AudioServer.set_bus_volume_db(2, linear_to_db(value))

# seed
@export var seed: int:
	set(value):
		seed = value
		seed(seed)



func get_leader() -> Actor:
	return party[0]


## Updates otherwise unset values.
func prepare_for_save() -> void:
	position = get_leader().node.position


## Called when the save is created.
func setup() -> void:
	randomize()
	seed = randi()
