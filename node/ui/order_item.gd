extends HBoxContainer


func set_actor(actor: Actor) -> void:
	#$HBox/Art.texture = actor.portrait
	$VBox/Name.text = actor.name
	$VBox/Health.max_value = actor.max_health
	$VBox/Health.value = actor.health
	
	actor.health_changed.connect($VBox/Health.set_value)
	actor.defeated.connect($IconPanel/Icon.set_modulate.bind(Color(1, 1, 1, 0.5)))
	actor.status_effect_added.connect(_on_status_effect_added)
	#actor.status_effect_removed.connect(_on_status_effect_removed)
	
	for status_effect: StatusEffect in actor.status_effects:
		_on_status_effect_added(status_effect)


func _on_status_effect_added(status_effect: StatusEffect) -> void:
	var icon: TextureRect = TextureRect.new()
	icon.name = "Status" + str(status_effect.type)
	
	icon.texture = AtlasTexture.new()
	icon.texture.atlas = preload("res://asset/status_effect_icons.png")
	icon.texture.region.size = Vector2(8, 8)
	icon.texture.region.position = Vector2(status_effect.type % 64, status_effect.type / 64) * 8
	
	$Extra/StatusEffects.add_child(icon)


func _on_status_effect_removed(status_effect: StatusEffect) -> void:
	$Extra/StatusEffects.get_node("Status" + str(status_effect.type)).queue_free()
