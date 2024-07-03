extends PanelContainer


func set_actor(actor: Actor) -> void:
	#$HBox/Art.texture = actor.portrait
	$HBox/VBox/Name.text = actor.name
	$HBox/VBox/Health.max_value = actor.max_health
	$HBox/VBox/Health.value = actor.health
	
	actor.turn_started.connect(_on_turn_started)
	actor.turn_ended.connect(_on_turn_ended)
	actor.health_changed.connect($HBox/VBox/Health.set_value)
	actor.defeated.connect($HBox/IconPanel/Icon.set_modulate.bind(Color(1, 1, 1, 0.5)))
	actor.status_effect_added.connect(_on_status_effect_added)
	actor.status_effect_removed.connect(_on_status_effect_removed)


func _on_turn_started() -> void:
	$HBox/VBox/Health.show_percentage = true
	get_tree().create_tween().tween_property(get_parent().get_parent(), "scroll_vertical", offset_top, 0.25).set_trans(Tween.TRANS_CUBIC)


func _on_turn_ended() -> void:
	$HBox/VBox/Health.show_percentage = false


func _on_status_effect_added(status_effect: StatusEffect) -> void:
	var icon: TextureRect = TextureRect.new()
	icon.name = "Status" + str(status_effect.type)
	
	icon.texture = AtlasTexture.new()
	icon.texture.atlas = preload("res://asset/status_effect.png")
	icon.texture.region.size = Vector2(8, 8)
	icon.texture.region.position = Vector2(status_effect.type % 64, status_effect.type / 64) * 8
	
	$HBox/Extra/StatusEffects.add_child(icon)


func _on_status_effect_removed(status_effect: StatusEffect) -> void:
	$HBox/Extra/StatusEffects.get_node("Status" + str(status_effect.type)).queue_free()
