class_name PlayerDetector extends Area2D


signal player_entered
signal player_exited

@export var free_on_enter: bool


func _ready() -> void:
	collision_layer = 0
	collision_mask = 0b10
	monitorable = false
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area2D) -> void:
	if area is ActorNode and area.resource == Save.leader:
		player_entered.emit()
		if free_on_enter: queue_free()


func _on_area_exited(area: Area2D) -> void:
	if area is ActorNode and area.resource == Save.leader:
		player_exited.emit()
