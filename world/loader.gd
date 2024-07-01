extends Node


func _ready():
	Data.load_file.call_deferred(-1)
