class_name PlayerDetector extends Area2D


signal player_entered
signal player_exited

@export var free_on_enter: bool


func _ready() -> void:
	collision_layer = 0
	collision_mask = 0b10
	monitorable = false
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is ActorNode and body.resource == Save.player:
		player_entered.emit()
		if free_on_enter: queue_free()


func _on_body_exited(body: Node2D) -> void:
	if body is ActorNode and body.resource == Save.player:
		player_exited.emit()
