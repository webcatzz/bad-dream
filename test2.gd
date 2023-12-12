extends Node2D

func _ready():
	add_child(SFX.new("text", Iso.DOWN, $Actor.position))
