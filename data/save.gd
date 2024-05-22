extends Resource


@export var leader: Actor = load("res://data/actor/party/woodcarver.tres")
@export var party: Array[Actor] = [leader]

# volume
@export var master_volume: float = 1
@export var music_volume: float = 1
@export var sfx_volume: float = 1
