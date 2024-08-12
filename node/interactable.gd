class_name Interactable extends Area2D


signal interacted_with


func interact() -> void:
	interacted_with.emit()



# internal

func _ready() -> void:
	collision_layer = 0b100
	collision_mask = 0
	monitoring = false
