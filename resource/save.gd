extends Resource
## Player data.


# party
@export var party: Array[Actor] = [load("res://resource/actor/woodcarver.tres"), Actor.new()]

# world
@export var scene_path: String
@export var position: Vector2

# settings
@export var master_volume: float = 1:
	set(value): master_volume = value; AudioServer.set_bus_volume_db(0, linear_to_db(value))
@export var music_volume: float = 0:
	set(value): music_volume = value; AudioServer.set_bus_volume_db(1, linear_to_db(value))
@export var sfx_volume: float = 1:
	set(value): sfx_volume = value; AudioServer.set_bus_volume_db(2, linear_to_db(value))

@export var use_wasd: bool # TODO

# hidden
@export var flags: PackedStringArray
@export var seed: int:
	set(value): seed = value; seed(value)



## Returns the first [Actor] in [member party].
func get_leader() -> Actor:
	return party[0]



# prepping

## Saves the resource.
func save() -> void:
	position = get_leader().node.position
	seed = randi()
	ResourceSaver.save(self)


## Called when the save is created.
func created() -> void:
	randomize()
	seed = randi()
