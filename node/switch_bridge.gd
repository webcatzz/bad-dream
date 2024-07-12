extends StaticBody2D


@onready var flag: String = Game.get_world_name() + "_bridges"


func _ready() -> void:
	if name in Data.get_flag(flag, []):
		_on_interact()


func _on_interact() -> void:
	$Sprite.region_rect.position.x = 32
	$Sprite.region_rect.size = Vector2(64, 32)
	$Sprite.offset = Vector2(24, 12)
	
	$Collision1.disabled = true
	$Collision2.disabled = true
	
	var bridges: Array = Data.get_flag(flag, [])
	bridges.append(name)
	Data.set_flag(flag, bridges)
