class_name Gate
extends Trigger

@export var scene: String
@export var gate: String


func send() -> void:
	Game.change_scene(scene, gate)


func receive() -> void:
	Game.player.global_position = global_position



# init

func _ready() -> void:
	super()
	triggered.connect(send)
	add_to_group("gate")
