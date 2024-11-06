class_name Interactable extends Area2D


signal interacted_with

@export var leader_position: Vector2i
@export var sprite: Sprite2D


func interact() -> void:
	Save.leader.node.walk_to(Iso.to_grid(position) + leader_position)
	interacted_with.emit()



# internal

func _ready() -> void:
	collision_layer = 0b100
	collision_mask = 0
	monitoring = false


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("move"):
		interact()


func _mouse_enter() -> void:
	sprite.material = preload("res://asset/vfx/outline.tres")


func _mouse_exit() -> void:
	sprite.material = null
