extends Node2D


signal interacted_with


@onready var flag: String = Game.get_world_name() + "_bridges"


func _ready() -> void:
	if name in Data.get_flag(flag, []):
		on_interact()


func on_interact() -> void:
	$Sprite.region_rect.position.x = 32
	$Sprite.region_rect.size = Vector2(64, 32)
	$Sprite.offset = Vector2(24, 12)
	$Sprite.z_index = -1
	
	$Collision.queue_free()
	
	var bridges: Array = Data.get_flag(flag, [])
	bridges.append(name)
	Data.set_flag(flag, bridges)
	
	interacted_with.emit()
