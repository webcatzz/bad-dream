extends Node2D


func _ready():
	var res = load("res://data/action/panic.tres")
	
	print(res.description)
	
	res.description = "AAAH"
	
	print(res.description)
	
	res = null
	
	print(load("res://data/action/panic.tres").description)
