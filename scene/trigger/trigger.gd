@icon("res://asset/editor/trigger.svg")
class_name Trigger
extends Area2D

signal triggered

enum Mode {
	CLICK,
	ENTER,
}

@export var mode: Mode
@export var once: bool


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		get_viewport().set_input_as_handled()
		
		Game.player.walk_to(global_position)
		Game.player.listening = false
		await Game.player.nav.navigation_finished
		Game.player.listening = true
		
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
			collision_layer = 0b10
			monitoring = false
		
		Mode.ENTER:
			collision_layer = 0
			input_pickable = false
			area_entered.connect(_on_area_entered)
	
	if once:
		triggered.connect(queue_free)
