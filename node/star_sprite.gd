extends Node2D


var velocity: Vector2


func _ready() -> void:
	$Sprite.region_rect.position.y = randi() % 4 * 5
	$Animator.speed_scale = randfn(1, 0.5)


func _on_player_near() -> void:
	$Animator.play("run")
	get_tree().create_tween().tween_property(self, "position", position + (position - Data.get_leader().node.position) * randfn(1, 0.25), 0.6).set_ease(Tween.EASE_OUT).set_delay(0.4)
