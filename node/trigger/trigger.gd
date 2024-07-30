class_name Trigger extends Area2D


signal triggered


@export_enum("Interact", "Enter") var mode: int
@export var record: bool


func trigger() -> void:
	triggered.emit()
	
	#if record:
		#var flag: String = Game.get_world_name() + "_triggers"
		#var recorded: Array = Data.get_flag(flag, [])
		#recorded.append(name)
		#Data.set_flag(flag, recorded)



# internal

func _ready() -> void:
	collision_layer = 0b100
	collision_mask = 0b10
	
	if mode: # Enter
		monitorable = false
		body_entered.connect(_trigger_if_body_is_player)
	else: # Interact
		monitoring = false
	
	#if record and get_path() in Data.get_flag(Game.get_world_name() + "_triggers", []):
		#emit_signal.call_deferred("triggered")


func _trigger_if_body_is_player(body: Node2D) -> void:
	if body is ActorNode and body.data == Data.party[0]: trigger()
