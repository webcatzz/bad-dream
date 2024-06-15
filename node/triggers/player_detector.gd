extends Area2D


signal player_entered
signal player_exited


func _ready() -> void:
	monitorable = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerActorNode: player_entered.emit()


func _on_body_exited(body: Node2D) -> void:
	if body is PlayerActorNode: player_exited.emit()
