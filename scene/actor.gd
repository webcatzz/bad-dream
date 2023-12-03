class_name ActorNode extends CharacterBody2D

@export var data: Actor


func _ready():
	data.node = self
	data.turn_started.connect($WhileSelected.set_visible.bind(true))
	data.turn_ended.connect($WhileSelected.set_visible.bind(false))
	Battle.started.connect($Facing.set_visible.bind(true))
	Battle.ended.connect($Facing.set_visible.bind(false))
	data.facing_changed.connect(set_facing)


func move(pos: Vector2):
	data.move(pos)
	create_tween().tween_property(self, "position", pos, 0.05)


func set_facing(direction: Vector2):
	$Facing.set_point_position(1, direction)
