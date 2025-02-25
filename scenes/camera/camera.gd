@tool
extends Node3D

@export_range(0.001, 100.0, 0.001, "or_greater", "suffix:m") var zoom: float = 16.0:
	set(value):
		zoom = value
		get_child(0).size = value

@export_range(0.0, 100.0, 0.001, "or_greater", "suffix:m") var distance: float = 16.0:
	set(value):
		distance = value
		get_child(0).position.z = value
