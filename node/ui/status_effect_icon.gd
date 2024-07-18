extends HBoxContainer


func set_data(status_effect: StatusEffect, actor: Actor) -> void:
	$Frame/Icon.region_rect.position = Vector2(status_effect.type % 64, status_effect.type / 64) * 8
	$Name.text = status_effect.get_type_string()
	$Duration.text = "for " + str(status_effect.duration) + " turns"


func hide_text() -> void:
	$Name.visible = false
	$Duration.visible = false
