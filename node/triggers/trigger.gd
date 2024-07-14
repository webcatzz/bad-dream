class_name Trigger extends Area2D
## Base class for triggers.


signal triggered


@export_enum("Interact", "Enter") var mode: int ## The trigger condition.

@export var record: bool ## Whether to record this trigger's state in Data.
var flag: String


## Virtual function for child classes.
func trigger() -> void:
	triggered.emit()
	
	if record:
		var flag: String = Game.get_world_name() + "_triggers"
		var recorded: Array = Data.get_flag(flag, [])
		recorded.append(name)
		Data.set_flag(flag, recorded)



# internal

func _ready() -> void:
	set_collision_layer_value(1, false)
	if mode: # Enter
		body_entered.connect(_trigger_if_body_is_party_leader)
	else: # Interact
		set_collision_mask_value(1, false)
		set_collision_layer_value(3, true)
	
	if record and get_path() in Data.get_flag(Game.get_world_name() + "_triggers", []):
		emit_signal.call_deferred("triggered")


func _trigger_if_body_is_party_leader(body: Node2D) -> void:
	if body is PlayerActorNode: trigger()
