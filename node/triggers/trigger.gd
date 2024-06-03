class_name Trigger extends Area2D
## Base class for triggers.


## The trigger condition.
## [code]0[/code] triggers on interaction, while [code]1[/code] triggers when a body enters it.
@export_enum("Interact", "Enter") var mode: int


## Virtual function for child classes.
func trigger() -> void:
	pass



# internal

func _ready() -> void:
	set_collision_layer_value(1, false)
	if mode: # Enter
		body_entered.connect(_trigger_if_body_is_party_leader)
	else: # Interact
		set_collision_mask_value(1, false)
		set_collision_layer_value(2, true)


func _trigger_if_body_is_party_leader(body: Node2D) -> void:
	if body is ActorNode and body.data == Game.data.leader: trigger()
