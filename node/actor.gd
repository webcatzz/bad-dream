class_name ActorNode extends CharacterBody2D


@export var data: Actor


func _ready() -> void:
	if data not in Data.party:
		data = data.duplicate()
		data.position = Iso.to_grid(position)
		data.node = self
	
	data.reoriented.connect(_on_reoriented)


func _on_reoriented() -> void:
	create_tween().tween_property(self, "position", Iso.from_grid(data.position), 0.05)
