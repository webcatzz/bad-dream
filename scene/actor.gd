class_name ActorNode extends CharacterBody2D

@export var data: Actor


func _ready():
	data.node = self
	data.turn_started.connect($Selector.set_visible.bind(true))
	data.turn_ended.connect($Selector.set_visible.bind(false))


func move(pos: Vector2):
	create_tween().tween_property(self, "position", pos, 0.05)
	data.move(pos)
