class_name Trigger
extends Area2D

signal triggered

enum Mode {
	CLICK,
	ENTER,
}

@export var mode: Mode


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		get_viewport().set_input_as_handled()
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
			input_event.connect(_on_input_event)
		
		Mode.ENTER:
			collision_layer = 0
			input_pickable = false
			area_entered.connect(_on_area_entered)
