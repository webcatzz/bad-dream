extends Resource


# party
@export var party: Array[Actor] = [load("res://data/actor/woodcarver.tres"), Actor.new(), Actor.new()]

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
@export var seed: int


func _init() -> void:
	master_volume = master_volume
	music_volume = music_volume
	sfx_volume = sfx_volume


func get_leader() -> Actor:
	return party[0]
