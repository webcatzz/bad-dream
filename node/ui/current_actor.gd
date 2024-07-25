extends HBoxContainer


func update(actor: Actor) -> void:
	# clearing
	for connection: Dictionary in get_incoming_connections():
		if connection.callable != update:
			connection.signal.disconnect(connection.callable)
	for child: Control in $StatusEffects.get_children():
		child.queue_free()
	
	$Art/Title/HBox/Name.text = actor.name
	$Art/HealthBar.max_value = actor.max_health
	$Art/TilesBar.max_value = actor.tiles_per_turn
	$Art/ActionsBar.max_value = actor.actions_per_turn
	
	_on_health_changed()
	_on_path_changed()
	_on_action_taken()
	for status_effect: StatusEffect in actor.status_effects:
		_on_status_effect_added(status_effect)
	
	actor.health_changed.connect(_on_health_changed.unbind(1))
	actor.action_taken.connect(_on_action_taken)
	actor.path_extended.connect(_on_path_changed)
	actor.path_backtracked.connect(_on_path_changed)
	actor.status_effect_added.connect(_on_status_effect_added)


func animate_bar(value: int, bar: TextureProgressBar) -> void:
	bar.value = value
	bar.get_child(0).text = str(bar.value)
	get_tree().create_tween().tween_property(bar.get_child(1), "rotation", value * -PI/2, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)



# internal

func _on_health_changed() -> void:
	animate_bar(Battle.current_actor.health, $Art/HealthBar)


func _on_path_changed() -> void:
	animate_bar(Battle.current_actor.tiles_per_turn - Battle.current_actor.tiles_traveled, $Art/TilesBar)


func _on_action_taken() -> void:
	animate_bar(Battle.current_actor.actions_per_turn - Battle.current_actor.actions_taken, $Art/ActionsBar)


func _on_status_effect_added(status_effect: StatusEffect) -> void:
	var icon: HBoxContainer = preload("res://node/ui/status_effect_icon.tscn").instantiate()
	icon.name = "Status" + str(status_effect.type)
	icon.set_data(status_effect, Battle.current_actor)
	$StatusEffects.add_child(icon)
