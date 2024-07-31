class_name ActorNode extends CharacterBody2D


@export var data: Actor


func _ready() -> void:
	if data not in Data.party:
		data = data.duplicate()
		data.position = Iso.to_grid(position)
	
	data.position_changed.connect(_on_position_changed)


func _on_position_changed() -> void:
	create_tween().tween_property(self, "position", Iso.from_grid(data.position), 0.05)
