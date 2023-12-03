extends Node

var player: Resource
var party: Array[Resource] = []


func _ready():
	load_data()


func save_data():
	ResourceSaver.save(player)
	for actor: Resource in party:
		ResourceSaver.save(actor)


func load_data():
	player = load("res://data/player.tres")
	for actor_name: String in player.party:
		party.append(load("res://data/actor/" + actor_name + ".tres"))
