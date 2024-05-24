extends Resource


@export var leader: Actor = load("res://data/actor/party/woodcarver.tres")
@export var party: Array[Actor] = [leader]

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


func _init():
	master_volume = master_volume
	music_volume = music_volume
	sfx_volume = sfx_volume
