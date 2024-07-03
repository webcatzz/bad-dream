extends PanelContainer


func set_actor(actor: Actor) -> void:
	#$HBox/Art.texture = actor.portrait
	$HBox/VBox/Name.text = actor.name
	$HBox/VBox/Health.max_value = actor.max_health
	$HBox/VBox/Health.value = actor.health
	
	actor.turn_started.connect($HBox/ActiveIcon.set_visible.bind(true))
	actor.turn_ended.connect($HBox/ActiveIcon.set_visible.bind(false))
	actor.health_changed.connect($HBox/VBox/Health.set_value)
	actor.defeated.connect($HBox/Art.set_modulate.bind(Color(1, 1, 1, 0.5)))
	actor.status_effect_added.connect(_on_status_effect_added)
	actor.status_effect_removed.connect(_on_status_effect_removed)


func _on_status_effect_added(status_effect: StatusEffect) -> void:
	var icon: TextureRect = TextureRect.new()
	icon.name = "Status" + str(status_effect.type)
	
	icon.texture = AtlasTexture.new()
	icon.texture.atlas = preload("res://asset/status_effect.png")
	icon.texture.region.size = Vector2(8, 8)
	icon.texture.region.position = Vector2(status_effect.type % 64, status_effect.type / 64) * 8
	
	$HBox/StatusEffects.add_child(icon)


func _on_status_effect_removed(status_effect: StatusEffect) -> void:
	$HBox/StatusEffects.get_node("Status" + str(status_effect.type)).queue_free()
