class_name Trigger extends Area2D
## Base class for triggers.


signal triggered


@export_enum("Interact", "Enter") var mode: int ## The trigger condition.


## Virtual function for child classes.
func trigger() -> void:
	triggered.emit()



# internal

func _ready() -> void:
	set_collision_layer_value(1, false)
	if mode: # Enter
		body_entered.connect(_trigger_if_body_is_party_leader)
	else: # Interact
		set_collision_mask_value(1, false)
		set_collision_layer_value(2, true)


func _trigger_if_body_is_party_leader(body: Node2D) -> void:
	if body is PlayerActorNode: trigger()
