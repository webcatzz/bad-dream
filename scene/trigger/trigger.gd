@icon("res://asset/editor/trigger.svg")
class_name Trigger
extends Area2D

signal triggered

enum Mode {
	CLICK,
	ENTER,
}

@export var mode: Mode
@export var move_to: Vector2i
@export var free_after: bool


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		get_viewport().set_input_as_handled()
		Game.player.walk_to(global_position + Game.grid.tile_to_point(move_to))
		triggered.emit()


func _on_area_entered(area: Area2D) -> void:
	assert(area == Game.player)
	triggered.emit()



# init

func _ready() -> void:
	monitorable = false
	
	match mode:
		Mode.CLICK:
			collision_mask = 0
		
		Mode.ENTER:
			collision_layer = 0
			input_pickable = false
			area_entered.connect(_on_area_entered)
	
	if free_after:
		triggered.connect(queue_free)
