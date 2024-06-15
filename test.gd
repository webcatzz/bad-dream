extends Node2D


func _ready():
	var res = load("res://resource/action/panic.tres")
	
	print(res.description)
	
	res.description = "AAAH"
	
	print(res.description)
	
	res = null
	
	print(load("res://resource/action/panic.tres").description)
