extends Resource
## Player data.


# main
@export var party: Array[Actor] = [load("res://resource/actor/woodcarver.tres")]
@export var flags: PackedStringArray
@export var seed: int:
	set(value): seed = value; seed(value)

# world
@export var scene_path: String
@export var position: Vector2

# settings
@export var master_volume: float = 1:
	set(value): master_volume = value; AudioServer.set_bus_volume_db(0, linear_to_db(value))
@export var music_volume: float = 1:
	set(value): music_volume = value; AudioServer.set_bus_volume_db(1, linear_to_db(value))
@export var sfx_volume: float = 1:
	set(value): sfx_volume = value; AudioServer.set_bus_volume_db(2, linear_to_db(value))

@export var use_wasd: bool # TODO



## Returns the first [Actor] in [member party].
func get_leader() -> Actor:
	return party[0]



# prepping

## Sets otherwise unset values in preparation for saving.
func prepare_for_save(idx: int) -> void:
	position = get_leader().node.position
	seed = randi()


## Called when the save is created.
func created() -> void:
	randomize()
	seed = randi()
